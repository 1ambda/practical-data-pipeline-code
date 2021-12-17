package mkt.udon

import mkt.udon.config.UdonProfileStreamConfig
import mkt.udon.core.Environment
import mkt.udon.entity.{UserEvent, UserEventRaw, UserProfile}
import mkt.udon.infra.spark.SparkBase
import mkt.udon.infra.spark.storage.DynamoSink
import org.apache.log4j.LogManager
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.{Dataset, SparkSession}
import org.json4s.jackson.Serialization
import org.json4s.{DefaultFormats, Formats}
import pureconfig.generic.auto._

object UdonProfileStream extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    import session.implicits._

    /**
     * 환경변수 추출 및 설정
     */
    implicit val configHint = Environment.buildConfigHint[UdonProfileStreamConfig]()
    val config = Environment.getConfigOrThrow[UdonProfileStreamConfig]()


    /**
     * 데이터 추출 및 가공
     */
    val dfRaw = session.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", config.kafkaBroker)
      .option("subscribe", config.kafkaTopic)
      .option("groupIdPrefix", config.kafkaConsumerGroup)
      .option("startingOffsets", config.kafkaOffsetStarting)
      .load()

    // stringified JSON 을 Case Class 로 컨버팅 합니다. 만약 Avro 를 쓴다면 이러한 과정 없이 사용할 수 있습니다.
    val dfConverted = dfRaw
      .selectExpr("CAST(value AS STRING)").as[String]
      .map(raw => {
        implicit val default: Formats = DefaultFormats.preservingEmptyValues
        val parsed = Serialization.read[UserEventRaw](raw)
        parsed.convert()
      })

    /**
     * 데이터 적재
     */
    val dfWritten = dfConverted.writeStream
      .queryName("UserProfileStream")
      .foreachBatch((dsUserEvent: Dataset[UserEvent], batchId: Long) => {
        // 사용자 기준으로 repartition 해 하나의 파티션 내에서 해당 사용자 이벤트를 모드 처리할 수 있도록 합니다
        val repartitioned = dsUserEvent.repartition(config.dynamoPartitionCount, col("userId"))
        repartitioned.foreachPartition((iter: Iterator[UserEvent]) => {
          // Dynamo Client 생성 (@ThreadSafe)
          val dynamoClient = DynamoSink.buildClient(dynamoTable = config.dynamoTable, dynamoRegion = config.dynamoRegion)

          // 사용자 마다 그룹화 해 사용자별로 이벤트 시간순 정렬을 할 수 있도록 합니다.
          val groupedByUser = iter.toList.groupBy(u => u.userId)
          groupedByUser.foreach(kv => {
            val userId = kv._1
            val userEvents = kv._2.sortBy(x => -x.eventTime) // 시간순 내림차순 정렬

            // 사용자 Profile 을 Dynamo 에서 가져오고 없을 경우 만듭니다
            val existing = DynamoSink.getItem[UserProfile](dynamoClient, keyName = "specifier", userId)
              .getOrElse(UserProfile.buildEmpty(userId))

            userEvents.foreach(event => {
              existing.update(userEvent = event, maxCountView = config.maxCountView, maxCountOrder = config.maxCountOrder)
            })

            DynamoSink.putItem(dynamoClient, existing, config.dynamoExpireDays)
          })
        })
      })
      .option("checkpointLocation", config.checkpointLocation)
      .start()

    dfWritten.awaitTermination()
  }
}

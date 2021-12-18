package mkt.udon

import mkt.udon.config.UdonProfileStreamConfig
import mkt.udon.core.common.Environment
import mkt.udon.core.entity.UserEvent
import mkt.udon.entity.UdonProfileStateFunc
import mkt.udon.infra.spark.SparkBase
import org.apache.log4j.LogManager
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.streaming.{OutputMode, Trigger}
import org.apache.spark.sql.{Dataset, SparkSession}
import pureconfig.generic.auto._

object UdonProfileStream extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  val APP = "UserProfileStream"

  override def driver(session: SparkSession): Unit = {
    import session.implicits._

    /**
     * 환경변수 추출 및 설정
     */
    implicit val configHint = Environment.buildConfigHint[UdonProfileStreamConfig]()
    val config = Environment.getConfigOrThrowForApp[UdonProfileStreamConfig](APP)


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
      .map(UserEvent.convertFromRaw)

    /**
     * 데이터 적재
     */
    val dfWritten = dfConverted.writeStream
      .queryName(APP)
      .trigger(Trigger.ProcessingTime("1 seconds"))
      .outputMode(OutputMode.Append())
      .foreachBatch((dsUserEvent: Dataset[UserEvent], batchId: Long) => {
        // 사용자 기준으로 repartition 해 하나의 파티션 내에서 해당 사용자 이벤트를 모드 처리할 수 있도록 합니다
        val repartitioned = dsUserEvent.repartition(config.dynamoPartitionCount, col("userId"))

        // 파티션 처리 함수를 호출합니다.
        repartitioned.foreachPartition((iter: Iterator[UserEvent]) => {
          UdonProfileStateFunc.handlePartition(config, iter)
        })
      })
      .option("checkpointLocation", config.checkpointLocation)
      .start()

    dfWritten.awaitTermination()
  }
}

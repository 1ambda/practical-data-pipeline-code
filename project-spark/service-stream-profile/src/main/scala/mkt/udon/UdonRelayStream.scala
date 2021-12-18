package mkt.udon

import mkt.udon.config.UdonRelayStreamConfig
import mkt.udon.core.common.Environment
import mkt.udon.core.entity.UserEvent
import mkt.udon.infra.spark.SparkBase
import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.streaming.{OutputMode, Trigger}
import pureconfig.generic.auto._

object UdonRelayStream extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  val APP = "UserRelayStream"

  override def driver(session: SparkSession): Unit = {
    import session.implicits._

    /**
     * 환경변수 추출 및 설정
     */
    implicit val configHint = Environment.buildConfigHint[UdonRelayStreamConfig]()
    val config = Environment.getConfigOrThrowForApp[UdonRelayStreamConfig](APP)

    /**
     * 데이터 추출 및 가공
     */
    val dfRaw = session.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", config.sourceKafkaBroker)
      .option("subscribe", config.sourceKafkaTopic)
      .option("groupIdPrefix", config.sourceKafkaConsumerGroup)
      .option("startingOffsets", config.sourceKafkaOffsetStarting)
      .load()

    // stringified JSON 을 Case Class 로 컨버팅 합니다. 만약 Avro 를 쓴다면 이러한 과정 없이 사용할 수 있습니다.
    val dfConverted = dfRaw
      .selectExpr("CAST(value AS STRING)").as[String]
      .map(UserEvent.convertFromRaw)

    /**
     * 데이터 적재
     */

    // UserEvent.userId 를 Kafka Partition Key 로 사용합니다.
    val dfJson = dfConverted.selectExpr("CAST(userId AS STRING) AS key", "to_json(struct(*)) AS value")

    val dfWritten = dfJson.writeStream
      .queryName(APP)
      .outputMode(OutputMode.Append())
      .trigger(Trigger.Continuous("1 seconds"))
      .format("kafka")
      .option("kafka.bootstrap.servers", config.sinkKafkaBroker)
      .option("topic", config.sinkKafkaTopic)
      .option("checkpointLocation", config.checkpointLocation)
      .start()

    dfWritten.awaitTermination()
  }
}

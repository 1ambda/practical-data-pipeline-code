package mkt.udon

import mkt.udon.core.Environment
import mkt.udon.infra.spark.SparkBase
import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession
import pureconfig.generic.auto._

object UdonProfileStream extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    val config = Environment.getConfigOrThrow[UdonProfileStreamConfig]()

    import session.implicits._

    val dfRaw = session.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", config.sourceKafkaBroker)
      .option("subscribe", config.sourceKafkaTopic)
      .option("groupIdPrefix", config.sourceKafkaConsumerGroup)
      .option("startingOffsets", config.sourceKafkaOffsetStarting)
      .load()

    val dfConverted = dfRaw.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
      .as[(String, String)]

    val dfWritten = dfConverted.writeStream
      .queryName("UdonProfileStream")
      .format("console")
      .option("checkpointLocation", config.sparkCheckpointLocation)
      .start()

    dfWritten.awaitTermination()
  }
}

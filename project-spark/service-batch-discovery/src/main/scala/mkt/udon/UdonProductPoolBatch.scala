package mkt.udon

import mkt.udon.infra.spark.SparkBase
import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession

object UdonProductPoolBatch extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    logger.info("Hello Recommendation")

    val resourcePath = getClass.getClassLoader.getResource("marketing_campaign.csv").getPath

    val df = session.read.format("csv")
      .option("inferSchema", "true")
      .option("header", "true")
      .option("sep", "\t")
      .load(resourcePath)

  }
}

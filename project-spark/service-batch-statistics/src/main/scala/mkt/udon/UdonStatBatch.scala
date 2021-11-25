package mkt.udon

import mkt.udon.core.Environment
import mkt.udon.infra.spark.SparkBase

import pureconfig.generic.auto._

import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession

object UdonStatBatch extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    val config = Environment.getConfigOrThrow[UdonStatBatchConfig]()

    val resourcePath = getClass.getClassLoader.getResource("ecommerce-event.csv").getPath
    val df = session.read.format("csv")
      .option("inferSchema", "true")
      .option("header", "true")
      .load(resourcePath)

    logger.info("Hello Statistics")
  }
}

package mkt.udon

import mkt.udon.infra.spark.SparkBase
import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession

object UdonRecomBatch extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    logger.info("Hello Recommendation")
  }
}

package mkt.udon.infra.spark

import mkt.udon.core.Environment
import org.apache.log4j.LogManager
import org.apache.spark.sql.SparkSession

trait SparkBase {

  val logger = LogManager.getRootLogger
  var session: SparkSession = null

  def driver(session: SparkSession): Unit

  def buildSession(): SparkSession = {
    var sessionBuilder = SparkSession.builder().enableHiveSupport()

    if (Environment.isLocalMode()) {
      sessionBuilder = sessionBuilder.master("local[*]")
      sessionBuilder = sessionBuilder.config("spark.sql.crossJoin.enabled", true)
    }

    val session = sessionBuilder.getOrCreate()

    // give the full control for the bucket owner
    // - https://docs.aws.amazon.com/ko_kr/emr/latest/ManagementGuide/emr-s3-acls.html
    val hadoopConf = session.sparkContext.hadoopConfiguration
    hadoopConf.set("fs.s3.canned.acl", "BucketOwnerFullControl")

    session
  }

  def main(args: Array[String]): Unit = {
    session = buildSession()

    try {
      driver(session)
    } catch {
      case t: Throwable =>
        logger.error("Application failed due to", t)
        session.stop()
    }
  }

}

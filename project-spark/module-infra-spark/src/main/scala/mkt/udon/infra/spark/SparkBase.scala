package mkt.udon.infra.spark

import mkt.udon.core.common.Environment
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

    session = sessionBuilder.getOrCreate()
    setupHadoopEnvironment(session)

    session
  }

  /**
   * 실제 Production 환경에서는
   * - 설정은 Cluster 의 spark-defaults.conf 환경을 따릅니다.
   * - AWS Key 는 Machine 의 IAM Role 을 이용합니다.
   *
   * 아래 코드에서는 로컬 테스팅을 위해 해당 설정들을 직접 세팅합니다.
   */
  def setupHadoopEnvironment(session: SparkSession): Unit = {
    if (!Environment.isLocalMode()) return

    val hadoopConf = session.sparkContext.hadoopConfiguration

    hadoopConf.set("fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    hadoopConf.set("fs.s3.canned.acl", "BucketOwnerFullControl")
    // hadoopConf.set("fs.s3a.access.key", accessKey)
    // hadoopConf.set("fs.s3a.secret.key", secretKey)
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

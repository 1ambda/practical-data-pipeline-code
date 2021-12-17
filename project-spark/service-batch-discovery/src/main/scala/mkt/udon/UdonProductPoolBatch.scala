package mkt.udon

import mkt.udon.config.UdonProductPoolBatchConfig
import mkt.udon.core.Environment
import mkt.udon.entity.UdonProductPoolEntity
import mkt.udon.infra.spark.SparkBase
import mkt.udon.infra.spark.storage.DynamoSink
import org.apache.log4j.LogManager
import org.apache.spark.sql.{DataFrame, SparkSession}
import pureconfig.generic.auto._

object UdonProductPoolBatch extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {

    /**
     * 환경변수 추출 및 설정
     */
    implicit val configHint = Environment.buildConfigHint[UdonProductPoolBatchConfig]()
    val config = Environment.getConfigOrThrow[UdonProductPoolBatchConfig]
    setupHadoopEnvironment(config.awsAccessKeyLocal, config.awsSecretKeyLocal)

    /**
     * 데이터 추출 및 가공
     */
    val partitionSnapshot = config.partitionSnapshot
    val partitionMetricStart = config.partitionMetricStart
    val partitionMetricEnd = config.partitionMetricEnd
    val dfUserEvent = readUserEvent(session = session,
      partitionMetricStart = partitionMetricStart, partitionMetricEnd = partitionMetricEnd)

    val dsResult = UdonProductPoolEntity.convert(
      session,
      dfUserEvent = dfUserEvent,
      maxElementCount = config.maxElementCount)

    /**
     * 데이터 적재: Parquet
     */

    /**
     * 데이터 적재: Dynamo
     */
    DynamoSink.writePartition(config.dynamoTable, config.dynamoRegion, config.expireDays, dsResult)
  }

  def readUserEvent(session: SparkSession,
                    partitionMetricStart: String, partitionMetricEnd: String): DataFrame = {

    if (Environment.isLocalMode()) {
      val resourcePath = getClass.getClassLoader.getResource("ecommerce.csv").getPath

      val df = session.read.format("csv")
        .option("inferSchema", "true")
        .option("header", "true")
        .load(resourcePath)

      return df
    }

    return session.sql(
      s"""
         |SELECT *
         |FROM airbnb_db.user_client_event
         |WHERE part BETWEEN ${partitionMetricStart} AND ${partitionMetricEnd}
         |""".stripMargin)
  }
}

package mkt.udon

import mkt.udon.config.UdonProductPoolBatchConfig
import mkt.udon.core.Environment
import mkt.udon.entity.UdonProductPoolEntity
import mkt.udon.infra.spark.SparkBase
import mkt.udon.infra.spark.storage.{DynamoSink, ParquetSink}
import org.apache.log4j.LogManager
import org.apache.spark.sql.functions.lit
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}
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
     * 데이터 저장: Parquet
     *
     * `part` 를 파티션 컬럼으로 지정해 추가합니다.
     * Hive Static Partitioning 을 이용하면 Hive 로 읽을 경우엔 파티셔닝 컬럼이 자동으로 SELECT 시에 붙지만,
     * Parquet 를 직접 읽을 경우엔 존재하지 않으므로 Parquet 를 직접 읽는 사용자를 위해 추가합니다.
     */
    val dfPersistedParquet = dsResult.withColumn("part", lit(partitionSnapshot))
      .repartition(config.parquetPartitionCount)
    val parquetLocation = ParquetSink.buildLocation(config.parquetPrefix, partitionSnapshot)
    ParquetSink.write(session, dfPersistedParquet, parquetLocation, SaveMode.valueOf(config.parquetWriteMode))

    /**
     * 데이터 저장: Dynamo
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

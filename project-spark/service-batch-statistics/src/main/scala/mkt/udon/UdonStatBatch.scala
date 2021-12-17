package mkt.udon

import mkt.udon.config.UdonStatBatchConfig
import mkt.udon.core.{Environment, TimeUtil}
import mkt.udon.entity.UdonStatEntity
import mkt.udon.infra.spark.SparkBase
import mkt.udon.infra.spark.storage.{JdbcSink, ParquetSink}
import org.apache.log4j.LogManager
import org.apache.spark.sql.functions._
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}
import pureconfig.generic.auto._

object UdonStatBatch extends SparkBase {
  override val logger = LogManager.getLogger(this.getClass.getName)

  override def driver(session: SparkSession): Unit = {
    /**
     * 환경변수 추출 및 설정
     */
    implicit val configHint = Environment.buildConfigHint[UdonStatBatchConfig]()
    val config = Environment.getConfigOrThrow[UdonStatBatchConfig]
    setupHadoopEnvironment(config.awsAccessKeyLocal, config.awsSecretKeyLocal)

    /**
     * 데이터 추출 및 가공
     */
    val partition = config.partitionSnapshot
    val dfPropertyMeta = readPropertyMeta(partition, session)
    val dfPropertySales = readPropertySales(partition, session)
    val dfPropertyReview = readPropertyReview(partition, session)

    var dfResult = UdonStatEntity.convert(session, partition,
      dfPropertyMeta = dfPropertyMeta,
      dfPropertySales = dfPropertySales,
      dfPropertyReview = dfPropertyReview)

    // 사이즈가 작을 경우 추가적인 연산을 위해 캐싱할 수 있습니다.
    dfResult = dfResult.cache()

    /**
     * 데이터 저장: Parquet
     *
     * `part` 를 파티션 컬럼으로 지정해 추가합니다.
     * Hive Static Partitioning 을 이용하면 Hive 로 읽을 경우엔 파티셔닝 컬럼이 자동으로 SELECT 시에 붙지만,
     * Parquet 를 직접 읽을 경우엔 존재하지 않으므로 Parquet 를 직접 읽는 사용자를 위해 추가합니다.
     */
    val dfPersistedParquet = dfResult.withColumn("part", lit(partition))
      .repartition(config.parquetPartitionCount)
    val parquetLocation = ParquetSink.buildLocation(config.parquetPrefix, partition)
    ParquetSink.write(session, dfPersistedParquet, parquetLocation, SaveMode.valueOf(config.parquetWriteMode))

    /**
     * 데이터 저장: JDBC
     *
     * `part` 를 파티션 컬럼으로 지정해 추가합니다. Hive 테이블과 달라질 수 있기 때문에 별도 가공을 수행합니다.
     */
    val connectionUrl = s"jdbc:mysql://${config.jdbcHost}:${config.jdbcPort}/${config.jdbcSchema}"
    val partitionColumns = List(col("property_id"))

    val jdbcPartitionValue = TimeUtil.convertPartitionToSqlTimestamp(partition)
    val dfPersistedJdbc = dfResult.withColumn("part", lit(jdbcPartitionValue))
      .repartition(config.jdbcPartitionCount, partitionColumns: _*)

    JdbcSink.delete(jdbcUrl = connectionUrl, jdbcTable = config.jdbcTable,
      jdbcUsername = config.jdbcUsername, jdbcPassword = config.jdbcPassword,
      partitionColName = "part", partitionColValue = jdbcPartitionValue
    )

    JdbcSink.write(session, dfPersistedJdbc,
      jdbcUrl = connectionUrl, jdbcTable = config.jdbcTable,
      jdbcUsername = config.jdbcUsername, jdbcPassword = config.jdbcPassword)
  }

  def readPropertyMeta(partition: String, session: SparkSession): DataFrame = {

    if (Environment.isLocalMode()) {
      val resourcePath = getClass.getClassLoader.getResource("airbnb_listings.csv").getPath

      val df = session.read.format("csv")
        .option("inferSchema", "true")
        .option("header", "true")
        .option("quote", "\"")
        .option("escape", "\"")
        .option("sep", ",")
        .option("multiline", "true")
        .load(resourcePath)

      return df
    }

    return session.sql(
      s"""
         |SELECT *
         |FROM airbnb_db.property_meta
         |WHERE part = ${partition}
         |""".stripMargin)

  }

  def readPropertySales(partition: String, session: SparkSession): DataFrame = {

    if (Environment.isLocalMode()) {
      val resourcePath = getClass.getClassLoader.getResource("airbnb_calendar.csv").getPath

      val df = session.read.format("csv")
        .option("inferSchema", "true")
        .option("header", "true")
        .option("quote", "\"")
        .option("escape", "\"")
        .option("sep", ",")
        .option("multiline", "true")
        .load(resourcePath)

      return df
    }

    return session.sql(
      s"""
         |SELECT *
         |FROM airbnb_db.property_sales
         |WHERE part = ${partition}
         |""".stripMargin)
  }

  def readPropertyReview(partition: String, session: SparkSession): DataFrame = {

    if (Environment.isLocalMode()) {
      val resourcePath = getClass.getClassLoader.getResource("airbnb_reviews.csv").getPath

      val df = session.read.format("csv")
        .option("inferSchema", "true")
        .option("header", "true")
        .option("quote", "\"")
        .option("escape", "\"")
        .option("sep", ",")
        .option("multiline", "true")
        .load(resourcePath)

      return df
    }

    return session.sql(
      s"""
         |SELECT *
         |FROM airbnb_db.property_review
         |WHERE part = ${partition}
         |""".stripMargin)
  }

  /**
   * 과제: Hive Create Table DDL 을 Spark 를 이용해 실행해봅니다.
   * - 실행하기 위해 Hive Metastore 를 Docker Compose 로 띄우고
   * - Hive Metastore URI 를 설정해야 합니다.
   */
  def createTable(config: UdonStatBatchConfig, session: SparkSession): Unit = {
    if (Environment.isLocalMode()) return

    // TODO: execute create table DDL
  }

  /**
   * 과제: Hive Create Table DDL 을 Spark 를 이용해 실행해봅니다.
   * - 실행하기 위해 Hive Metastore 를 Docker Compose 로 띄우고
   * - Hive Metastore URI 를 설정해야 합니다.
   */
  def createPartition(config: UdonStatBatchConfig, session: SparkSession): Unit = {
    if (Environment.isLocalMode()) return

    // TODO: execute create partition DDL
  }
}

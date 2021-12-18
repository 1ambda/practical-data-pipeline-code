package mkt.udon.infra.spark.storage

import mkt.udon.core.common.TimeUtil
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}

object ParquetSink {


  def write(session: SparkSession,
            dfTarget: DataFrame,
            parquetLocation: String,
            parquetSaveMode: SaveMode): Unit = {

    dfTarget
      .write
      .mode(parquetSaveMode)
      .options(Map(
        ("parquet.enable.dictionary", "true"),
        ("parquet.block.size", s"${32 * 1024 * 1024}"),
        ("parquet.page.size", s"${2 * 1024 * 1024}"),
        ("parquet.dictionary.page.size", s"${8 * 1024 * 1024}")
      ))
      .parquet(parquetLocation)
  }

  /** *
   * Partition Value 로 부터 저장할 Parquet Location 을 빌드합니다.
   *
   * @param s3Prefix
   * @param partitionValue yyyyMMdd 를 가정
   */
  def buildLocation(prefix: String, partition: String): String = {
    val partitionPath = TimeUtil.convertPartitionToDateSlashString(partition)
    return s"${prefix}/${partitionPath}"
  }
}

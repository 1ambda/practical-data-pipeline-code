package mkt.udon.core

import java.time.{Instant, LocalDate}
import java.time.format.DateTimeFormatter

object TimeUtil {

  /**
   * @param partition 'yyyyMMdd' formatted String
   */
  def convertPartitionToDateString(partition: String): String = {
    val formatterInput = DateTimeFormatter.ofPattern("yyyyMMdd")
    val formatterOutput = DateTimeFormatter.ofPattern("yyyy-MM-dd")
    val parsed = LocalDate.parse(partition, formatterInput)

    return parsed.format(formatterOutput)
  }

  /**
   * @param partition 'yyyyMMdd' formatted String
   */
  def convertPartitionToDateSlashString(partition: String): String = {
    val formatterInput = DateTimeFormatter.ofPattern("yyyyMMdd")
    val formatterOutput = DateTimeFormatter.ofPattern("yyyy/MM/dd")
    val parsed = LocalDate.parse(partition, formatterInput)

    return parsed.format(formatterOutput)
  }

  /**
   * @param partition 'yyyyMMdd' formatted String
   */
  def convertPartitionToSqlTimestamp(partition: String): java.sql.Timestamp = {
    val formatterInput = DateTimeFormatter.ofPattern("yyyyMMdd")
    val formatterOutput = DateTimeFormatter.ofPattern("yyyy/MM/dd")
    val parsed = LocalDate.parse(partition, formatterInput).atStartOfDay()

    return java.sql.Timestamp.valueOf(parsed)
  }

  def getExpireEpochSeconds(expireDays: Int): Long = {
    val updatedAt = Instant.now().toEpochMilli
    val expireTtl = (updatedAt + (expireDays * 86400 * 1000)) / 1000
    return expireTtl
  }
}

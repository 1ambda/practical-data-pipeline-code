package mkt.udon.infra.spark.storage

import org.apache.spark.sql.{Dataset, Row, SparkSession}

import java.sql.{Connection, DriverManager}

object JdbcSink {

  val DRIVER = "com.mysql.cj.jdbc.Driver"

  def write(session: SparkSession, dfTarget: Dataset[Row],
            jdbcUrl: String, jdbcTable: String,
            jdbcUsername: String, jdbcPassword: String,
           ): Unit = {

    dfTarget
      .write
      .mode("append")
      .format("jdbc")
      .option("driver", DRIVER)
      .option("url", jdbcUrl)
      .option("user", jdbcUsername)
      .option("password", jdbcPassword)
      .option("dbtable", jdbcTable)
      .option("truncate", "false")
      .save()
  }

  def delete(jdbcUrl: String, jdbcTable: String,
             jdbcUsername: String, jdbcPassword: String,
             partitionColName: String, partitionColValue: java.sql.Timestamp): Unit = {

    var connection: Connection = null

    try {
      Class.forName(DRIVER)
      connection = DriverManager.getConnection(jdbcUrl, jdbcUsername, jdbcPassword)

      // remove rows which are already existing and having the same partition value
      val query = s"DELETE FROM ${jdbcTable} WHERE `${partitionColName}` = ?"
      val preparedStatement = connection.prepareStatement(query)
      preparedStatement.setTimestamp(1, partitionColValue)
      preparedStatement.execute()

    } catch {
      case e: Exception =>
        throw e;

    } finally {
      if (connection != null) connection.close()
    }

  }

}

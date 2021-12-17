package mkt.udon.config

case class UdonStatBatchConfig(jdbcHost: String, jdbcPort: Int,
                               jdbcUsername: String, jdbcPassword: String,
                               jdbcSchema: String, jdbcTable: String,
                               jdbcPartitionCount: Int,
                               parquetPrefix: String, parquetWriteMode: String, parquetPartitionCount: Int,
                               awsAccessKeyLocal: String, awsSecretKeyLocal: String,
                               partitionSnapshot: String)

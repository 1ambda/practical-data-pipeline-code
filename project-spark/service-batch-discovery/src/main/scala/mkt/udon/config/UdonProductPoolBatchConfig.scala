package mkt.udon.config

case class UdonProductPoolBatchConfig(dynamoTable: String, dynamoRegion: String, dynamoPartitionCount: String,
                                      parquetPrefix: String, parquetWriteMode: String, parquetPartitionCount: Int,
                                      awsAccessKeyLocal: String, awsSecretKeyLocal: String,
                                      partitionSnapshot: String,
                                      partitionMetricStart: String,
                                      partitionMetricEnd: String,
                                      maxElementCount: Int, expireDays: Int)

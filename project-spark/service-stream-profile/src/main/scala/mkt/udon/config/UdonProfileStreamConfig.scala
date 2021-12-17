package mkt.udon.config

case class UdonProfileStreamConfig(checkpointLocation: String,
                                   dynamoTable: String,
                                   dynamoRegion: String,
                                   dynamoExpireDays: Int,
                                   dynamoPartitionCount: Int,
                                   kafkaBroker: String,
                                   kafkaTopic: String,
                                   kafkaConsumerGroup: String,
                                   kafkaOffsetStarting: String,
                                   maxCountView: Int,
                                   maxCountOrder: Int
                                  )

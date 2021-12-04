package mkt.udon

case class UdonProfileStreamConfig(sinkDynamoTable: String,
                                   sinkDynamoTtlDays: Int,
                                   sourceKafkaBroker: String,
                                   sourceKafkaTopic: String,
                                   sourceKafkaConsumerGroup: String,
                                   sourceKafkaOffsetStarting: String,
                                   sourceKafkaOffsetEnding: String,
                                  )

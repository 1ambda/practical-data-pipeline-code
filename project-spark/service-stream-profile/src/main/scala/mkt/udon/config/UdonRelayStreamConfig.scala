package mkt.udon.config

case class UdonRelayStreamConfig(checkpointLocation: String,
                                 sourceKafkaBroker: String,
                                 sourceKafkaTopic: String,
                                 sourceKafkaConsumerGroup: String,
                                 sourceKafkaOffsetStarting: String,
                                 sinkKafkaBroker: String,
                                 sinkKafkaTopic: String)

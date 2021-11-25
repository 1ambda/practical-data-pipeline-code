package mkt.udon

case class UdonStatBatchConfig(databaseHost: String, databasePort: Int,
                               databaseUsername: String, databasePassword: String,
                               databaseSchema: String, databaseTable: String,
                               partitionSnapshot: String)

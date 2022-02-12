locals {
  emr_cluster_spark_batch = "spark-batch"

  emr_release_5_34_0 = "emr-5.34.0"
  emr_release_6_5_0  = "emr-6.5.0"
}

locals {
  spot_default_factor = 0.8

  spot_on_demand_price_r5xlarge = 0.304
  spot_bid_price_r5xlarge       = format("%.2f", tonumber(local.spot_on_demand_price_r5xlarge) * tonumber(local.spot_default_factor))

  spot_on_demand_price_m5xlarge = 0.236
  spot_bid_price_m5_xlarge        = format("%.2f", tonumber(local.spot_on_demand_price_m5xlarge) * tonumber(local.spot_default_factor))
}
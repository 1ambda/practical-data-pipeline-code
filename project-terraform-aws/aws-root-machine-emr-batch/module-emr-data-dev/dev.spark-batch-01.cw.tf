#resource "aws_cloudwatch_metric_alarm" "emr_spark_batch_01_High-CPUUtilization" {
#  alarm_name          = "EMR-Master-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}/${var.environment}-High_CPUUtil"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#
#  period              = "300"
#  evaluation_periods  = "2"
#  datapoints_to_alarm = 2
#
#  # second
#  statistic         = "Average"
#  threshold         = "80"
#  alarm_description = ""
#
#  metric_name = "CPUUtilization"
#  namespace   = "AWS/EC2"
#
#  dimensions = {
#    InstanceId = data.aws_instance.emr_master_spark_batch_cluster_01.id
#  }
#
#  actions_enabled           = true
#  insufficient_data_actions = []
#  ok_actions                = []
#
#  alarm_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#}
#
#resource "aws_cloudwatch_metric_alarm" "emr_spark_batch_01_High-MemUtil" {
#  alarm_name          = "EMR-Master-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}/${var.environment}-High_MemUtil"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#
#  period              = "300"
#  evaluation_periods  = "2"
#  datapoints_to_alarm = 2
#
#  # second
#  statistic         = "Maximum"
#  threshold         = "80"
#  alarm_description = ""
#
#  metric_name = "MemoryUtilization"
#  namespace   = "System/Linux"
#
#  dimensions = {
#    InstanceId = data.aws_instance.emr_master_spark_batch_cluster_01.id
#  }
#
#  actions_enabled = true
#
#  insufficient_data_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#
#  ok_actions = []
#
#  alarm_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#}
#
#resource "aws_cloudwatch_metric_alarm" "emr_spark_batch_01_Has-SystemCheckFailure" {
#  alarm_name          = "EMR-Master-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}/${var.environment}-Has_SysCheckFailure"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#
#  period              = "300"
#  evaluation_periods  = "1"
#  datapoints_to_alarm = 1
#
#  # second
#  statistic         = "Sum"
#  threshold         = "1"
#  alarm_description = ""
#
#  metric_name = "StatusCheckFailed"
#  namespace   = "AWS/EC2"
#
#  dimensions = {
#    InstanceId = data.aws_instance.emr_master_spark_batch_cluster_01.id
#  }
#
#  actions_enabled           = true
#  insufficient_data_actions = []
#  ok_actions                = []
#
#  alarm_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#}
#
## EC2 Custom Metric (Disk, Memory)
#
#resource "aws_cloudwatch_metric_alarm" "emr_spark_batch_01_High-RootDiskUtil" {
#  alarm_name          = "EMR-Master-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}/${var.environment}-High_RootDiskUtil"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#
#  period              = "300"
#  evaluation_periods  = "2"
#  datapoints_to_alarm = 2
#
#  # second
#  statistic         = "Maximum"
#  threshold         = "80"
#  alarm_description = ""
#
#  metric_name = "DiskSpaceUtilization"
#  namespace   = "System/Linux"
#
#  dimensions = {
#    InstanceId = data.aws_instance.emr_master_spark_batch_cluster_01.id
#    MountPath  = local.emr_cw_root_disk_mount_path
#    Filesystem = local.emr_cw_root_disk_mount_fs
#  }
#
#  actions_enabled = true
#
#  insufficient_data_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#
#  ok_actions = []
#
#  alarm_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#}
#
#resource "aws_cloudwatch_metric_alarm" "emr_spark_batch_01_High-DataDiskUtil" {
#  alarm_name          = "EMR-Master-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}/${var.environment}-High_DataDiskUtil"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#
#  period              = "300"
#  evaluation_periods  = "2"
#  datapoints_to_alarm = 2
#
#  # second
#  statistic         = "Maximum"
#  threshold         = "80"
#  alarm_description = ""
#
#  metric_name = "DiskSpaceUtilization"
#  namespace   = "System/Linux"
#
#  dimensions = {
#    InstanceId = data.aws_instance.emr_master_spark_batch_cluster_01.id
#    MountPath  = local.emr_cw_data_disk_mount_path
#    Filesystem = local.emr_cw_data_disk_mount_fs
#  }
#
#  actions_enabled = true
#
#  insufficient_data_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#
#  ok_actions = []
#
#  alarm_actions = [
#    var.sns_topic_arn_cloudwatch_alarm,
#  ]
#}

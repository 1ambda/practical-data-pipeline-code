locals {
  bastion_instances = [
    {
      instanceId = aws_instance.bastion_public_01.id
      name       = local.purpose_bastion_public
      index      = "01"
      rootDevice = local.ebs_root_device_link
    },
  ]
}

resource "aws_cloudwatch_metric_alarm" "bastion_High-CPUUtilization" {
  count = length(local.bastion_instances)

  alarm_name          = "${lookup(local.bastion_instances[count.index], "name")}-${lookup(local.bastion_instances[count.index], "index")}/${var.environment}-High_CPUUtil"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "600"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  dimensions = {
    InstanceId = lookup(local.bastion_instances[count.index], "instanceId")
  }

  actions_enabled           = false
  insufficient_data_actions = []
  ok_actions                = []

  alarm_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]
}

resource "aws_cloudwatch_metric_alarm" "bastion_Has-SystemCheckFailure" {
  count = length(local.bastion_instances)

  alarm_name          = "${lookup(local.bastion_instances[count.index], "name")}-${lookup(local.bastion_instances[count.index], "index")}/${var.environment}-Has_SysCheckFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Sum"
  threshold         = "1"
  alarm_description = ""

  metric_name = "StatusCheckFailed"
  namespace   = "AWS/EC2"

  dimensions = {
    InstanceId = lookup(local.bastion_instances[count.index], "instanceId")
  }

  actions_enabled           = false
  insufficient_data_actions = []
  ok_actions                = []

  alarm_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]
}

# EC2 Custom Metric (Disk, Memory)

resource "aws_cloudwatch_metric_alarm" "bastion_High-RootDiskUtil" {
  count = length(local.bastion_instances)

  alarm_name          = "${lookup(local.bastion_instances[count.index], "name")}-${lookup(local.bastion_instances[count.index], "index")}/${var.environment}-High_RootDiskUtil"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Maximum"
  threshold         = "80"
  alarm_description = ""

  metric_name = "DiskSpaceUtilization"
  namespace   = "System/Linux"

  dimensions = {
    InstanceId = lookup(local.bastion_instances[count.index], "instanceId")
    MountPath  = "/"
    Filesystem = lookup(local.bastion_instances[count.index], "rootDevice")
  }

  actions_enabled = false

  insufficient_data_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]

  ok_actions = []

  alarm_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]
}

resource "aws_cloudwatch_metric_alarm" "bastion_High-MemUtil" {
  count = length(local.bastion_instances)

  alarm_name          = "${lookup(local.bastion_instances[count.index], "name")}-${lookup(local.bastion_instances[count.index], "index")}/${var.environment}-High_MemUtil"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Maximum"
  threshold         = "80"
  alarm_description = ""

  metric_name = "MemoryUtilization"
  namespace   = "System/Linux"

  dimensions = {
    InstanceId = lookup(local.bastion_instances[count.index], "instanceId")
  }

  actions_enabled = false

  insufficient_data_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]

  ok_actions = []

  alarm_actions = [
    // ${var.sns_topic_arn_cloudwatch_alarm},
  ]
}

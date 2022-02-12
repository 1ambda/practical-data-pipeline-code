locals {
  spark_batch_cluster_01 = {
    name_prefix = local.emr_cluster_spark_batch
    index = "01"
    release = local.emr_release_5_34_0

    // terraform doesn't array contained in a map
    applications = "Hadoop,Ganglia,Spark,Tez,Hive,HCatalog"

    master_instance_type = "m5.xlarge"
    master_instance_size = 1
    master_spot_enabled = true
    master_spot_bid_price = local.spot_bid_price_r5xlarge

    core_instance_type = "m5.xlarge"
    core_instance_size = 1
    core_spot_enabled = true
    core_spot_bid_price = local.spot_bid_price_r5xlarge

    task_instance_type = "r5.xlarge"
    task_instance_size = 1
    task_spot_enabled = true
    task_spot_bid_price = local.spot_bid_price_r5xlarge

    task_asg_enabled = false
    task_asg_min_capacity = 1
    task_asg_max_capacity = 1
    task_asg_decrease_threshold = 15.0
    task_asg_increase_threshold = 75.0

    root_ebs_volume_size = 100
    master_ebs_volume_size = 300
    core_ebs_volume_size = 300
    task_ebs_volume_size = 300
  }
}

data "template_file" "spark_batch_cluster_01_conf" {
  template = file("${path.root}/_template/template.emr-spark-batch.json")
}

resource "aws_emr_cluster" "spark_batch_cluster_01" {
  name = "${var.environment}-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}"

  release_label = lookup(local.spark_batch_cluster_01, "release")
  applications = split(",", lookup(local.spark_batch_cluster_01, "applications"))
  # log_uri = ""

  termination_protection = false
  keep_job_flow_alive_when_no_steps = true

  ec2_attributes {
    subnet_id = var.emr_subnet

    emr_managed_master_security_group = var.emr_master_managed_sg_id
    emr_managed_slave_security_group = var.emr_slave_managed_sg_id
    service_access_security_group = var.emr_service_managed_sg_id

    additional_master_security_groups = var.emr_master_additional_sg_id
    additional_slave_security_groups = var.emr_slave_additional_sg_id

    instance_profile = var.emr_profile_arn_instance
    key_name = var.emr_keypair
  }

  ebs_root_volume_size = lookup(local.spark_batch_cluster_01, "root_ebs_volume_size")

  master_instance_group {
    // MASTER
    name = lookup(local.spark_batch_cluster_01, "master_spot_enabled") ? "MasterIG_SPOT" : "MasterIG_STEADY"
    bid_price = lookup(local.spark_batch_cluster_01, "master_spot_enabled") ? lookup(local.spark_batch_cluster_01, "master_spot_bid_price"): ""
    instance_type = lookup(local.spark_batch_cluster_01, "master_instance_type")
    instance_count = lookup(local.spark_batch_cluster_01, "master_instance_size")

    ebs_config {
      size = lookup(local.spark_batch_cluster_01, "master_ebs_volume_size")
      type = "gp2"
    }
  }

  core_instance_group {
    // CORE
    name = lookup(local.spark_batch_cluster_01, "core_spot_enabled") ? "CoreIG_SPOT" : "CoreIG_STEADY"
    bid_price = lookup(local.spark_batch_cluster_01, "core_spot_enabled") ? lookup(local.spark_batch_cluster_01, "core_spot_bid_price") : ""
    instance_type = lookup(local.spark_batch_cluster_01, "core_instance_type")
    instance_count = lookup(local.spark_batch_cluster_01, "core_instance_size")

    ebs_config {
      size = lookup(local.spark_batch_cluster_01, "core_ebs_volume_size")
      type = "gp2"
      volumes_per_instance = 1
    }

    // disabled ASG for EMR Core Instance Group
    autoscaling_policy = ""
  }

  step {
    name = "Setup Hadoop Debugging"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar = "command-runner.jar"

      args = [
        "state-pusher-script",
      ]
    }
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes = [
      step,
      # bootstrap_action,
      master_instance_group,
      core_instance_group,
      log_uri,
      termination_protection,
      configurations,
    ]
  }

  tags = {
    Name = "emr-cluster-${var.environment}-${lookup(local.spark_batch_cluster_01, "name_prefix")}-${lookup(local.spark_batch_cluster_01, "index")}"
    Environment = var.environment
    Terraform = "true"

    Team = var.team

    Security_level = "low"

    Service = lookup(local.spark_batch_cluster_01, "name_prefix")
    Server = "analysis"

    Component = "${lookup(local.spark_batch_cluster_01, "name_prefix")}-${var.environment}"
  }

  service_role = var.emr_role_arn_cluster
  autoscaling_role = var.emr_role_arn_asg

  /**
   * 일반적으로 Configuration 파일은 S3 에 존재합니다.
   * 이 곳에서는 편의를 위해 로컬 파일을 사용합니다.
   */
  configurations = data.template_file.spark_batch_cluster_01_conf.rendered

  /**
   * S3 경로를 학습자 소유의 것으로 바꿀 수 있습니다.
   */
  // bootstrap_action {
  //   name = "emr-system-config"
  //   path = "s3://practical-data-pipeline/emr/template.emr-system-config.sh"
  // }

  // bootstrap_action {
  //   name = "emr-cloudwatch-collect"
  //   path = "s3://practical-data-pipeline/emr/template.emr-cloudwatch-collect.sh"
  // }

  // bootstrap_action {
  //   name = "emr-instance-tag"
  //   path = "s3://practical-data-pipeline/emr/template.emr-instance-tag.sh"
  // }
}

// TASK Group
resource "aws_emr_instance_group" "spark_batch_cluster_01_task" {
  cluster_id = aws_emr_cluster.spark_batch_cluster_01.id

  name = lookup(local.spark_batch_cluster_01, "task_spot_enabled") ? "TaskIG_SPOT_DYNAMIC" : "TaskIG_STEADY_DYNAMIC"
  instance_type = lookup(local.spark_batch_cluster_01, "task_instance_type")
  instance_count = lookup(local.spark_batch_cluster_01, "task_instance_size")
  bid_price = lookup(local.spark_batch_cluster_01, "task_spot_enabled") ? lookup(local.spark_batch_cluster_01, "task_spot_bid_price"): ""

  ebs_config {
    size = lookup(local.spark_batch_cluster_01, "task_ebs_volume_size")
    type = "gp2"
    volumes_per_instance = 1
  }

  // disabled ASG for EMR Core Instance Group
  // autoscaling_policy = lookup(local.spark_batch_cluster_01, "task_asg_enabled") ? data.template_file.asg_policy_spark_batch_enabled_01.rendered : ""
}

data "aws_instance" "emr_master_spark_batch_cluster_01" {
  filter {
    name = "private-dns-name"
    values = [
      aws_emr_cluster.spark_batch_cluster_01.master_public_dns]
  }
}

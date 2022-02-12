module "rds-hive-metastore-data-development" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.1.4"

  name           = "hive-metastore-${var.environment}"
  engine         = "aurora-mysql"
  engine_version = "5.7.12"
  instance_class = "db.t3.medium"
  instances = {
    01 = {}
    02 = {}
  }

  storage_encrypted   = true
  apply_immediately   = true
  skip_final_snapshot = true
  create_monitoring_role = false

  vpc_id  = var.vpc_id
  db_subnet_group_name = var.rds_hive_metastore_subnet_group
  vpc_security_group_ids = [var.rds_hive_metastore_sg_id]
  create_db_subnet_group = false
  create_security_group  = false

  # 이후 실습에서의 편의를 위해 고정된 값을 사용합니다.
  # Password 를 Terraform 에서 지정시 State 에 저장되므로 주의해야합니다.
  master_password                     = "admin1234"
  # master_password                     = random_password.hive-metastore.result
  create_random_password              = false

  db_parameter_group_name         = aws_db_parameter_group.hive-metastore.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.hive-metastore.name

  enabled_cloudwatch_logs_exports = []

  tags = {
    Environment = var.environment
    Team = var.team
  }
}

resource "random_password" "hive-metastore" {
  length = 10
}

resource "aws_db_parameter_group" "hive-metastore" {
  name        = "hive-metastore-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "hive-metastore-aurora-db-57-parameter-group"
  tags        = {
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_rds_cluster_parameter_group" "hive-metastore" {
  name        = "hive-metastore-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "hive-metastore-aurora-57-cluster-parameter-group"
  tags        = {
    Environment = var.environment
    Team = var.team
  }
}
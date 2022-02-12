locals {
  purpose_rds_hive_metastore = "rds-hive-metastore"
}

resource "aws_security_group" "rds_hive_metastore" {
  name = "${local.purpose_rds_hive_metastore}-${lower(var.environment)}"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "${local.purpose_rds_hive_metastore}-${lower(var.environment)}"
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "rds_allow_ssh_from_bastion" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  source_security_group_id = aws_security_group.bastion_public.id
  security_group_id = aws_security_group.rds_hive_metastore.id

  description = "Bastion"
}
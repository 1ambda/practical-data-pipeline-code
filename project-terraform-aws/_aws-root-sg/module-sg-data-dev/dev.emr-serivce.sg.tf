/**
 * MANAGED
 * - https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html#emr-sg-elasticmapreduce-master-private
 */
resource "aws_security_group" "emr_service_managed" {
  name = "emr-service-managed-${lower(var.environment)}"

  tags = {
    Terraform   = "true"
    Environment = var.environment_short
    Team        = var.team

    Name = "emr-service-managed-${lower(var.environment)}"
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "emr_master_service_allow_to_all" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = aws_security_group.emr_service_managed.id
}

resource "aws_security_group_rule" "emr_service_allow_8443_from_master_9443" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master_managed.id

  security_group_id = aws_security_group.emr_service_managed.id

  description = "EMR Service"
}

resource "aws_security_group_rule" "emr_service_allow_8443_from_master_8443" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master_managed.id

  security_group_id = aws_security_group.emr_service_managed.id

  description = "EMR Service"
}

resource "aws_security_group_rule" "emr_service_allow_8443_from_slave_8443" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave_managed.id

  security_group_id = aws_security_group.emr_service_managed.id

  description = "EMR Service"
}


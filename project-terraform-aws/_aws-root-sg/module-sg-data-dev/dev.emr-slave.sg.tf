/**
 * MANAGED
 * - https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html
 */
resource "aws_security_group" "emr_slave_managed" {
  name = "emr-slave-managed-${lower(var.environment)}"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "emr-slave-managed-${lower(var.environment)}"
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "emr_slave_managed_allow_to_all" {
  type      = "egress"
  from_port = -1
  to_port   = -1
  protocol  = "-1"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = "${aws_security_group.emr_slave_managed.id}"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_8443_from_service" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Service"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_udp_from_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_slave_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Slave (Self)"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_udp_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_master_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Master"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_tcp_from_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Slave (Self)"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_tcp_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Master"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_icmp_from_self" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_slave_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Slave (Self)"
}

resource "aws_security_group_rule" "emr_slave_managed_allow_icmp_from_master" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_master_managed.id

  security_group_id = aws_security_group.emr_slave_managed.id

  description = "EMR Master"
}

/**
 * ADDITIONAL
 */

resource "aws_security_group" "emr_slave_additional" {
  name = "emr-slave-additional-${lower(var.environment)}"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "emr-slave-additional-${lower(var.environment)}"
  }

  vpc_id = var.vpc_id
}

# BASTION -> EMR

resource "aws_security_group_rule" "emr_slave_additional_allow_all_tcp_from_bastion" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_public.id

  security_group_id = aws_security_group.emr_slave_additional.id

  description = "TCP Bastion"
}

resource "aws_security_group_rule" "emr_slave_additional_allow_all_udp_from_bastion" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.bastion_public.id

  security_group_id = aws_security_group.emr_slave_additional.id

  description = "UDP Bastion"
}

resource "aws_security_group_rule" "emr_slave_additional_allow_all_icmp_from_bastion" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.bastion_public.id

  security_group_id = aws_security_group.emr_slave_additional.id

  description = "ICMP Bastion"
}

# EMR -> BASTION

resource "aws_security_group_rule" "bastion_allow_all_icmp_from_emr_slave_additional" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_slave_additional.id

  security_group_id = aws_security_group.bastion_public.id

  description = "ICMP EMR Slave"
}

resource "aws_security_group_rule" "bastion_allow_all_tcp_from_emr_slave_additional" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave_additional.id

  security_group_id = aws_security_group.bastion_public.id

  description = "TCP EMR Slave"
}

resource "aws_security_group_rule" "bastion_allow_all_udp_from_emr_slave_additional" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_slave_additional.id

  security_group_id = aws_security_group.bastion_public.id

  description = "UDP EMR Slave"
}

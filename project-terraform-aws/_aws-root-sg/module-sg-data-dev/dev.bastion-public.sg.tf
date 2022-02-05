locals {
  purpose_bastion_public = "bastion-public"
}

resource "aws_security_group" "bastion_public" {
  name = "${local.purpose_bastion_public}-${lower(var.environment)}"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "${local.purpose_bastion_public}-${lower(var.environment)}"
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "bastion_allow_to_all" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.bastion_public.id
}

resource "aws_security_group_rule" "bastion_allow_ssh_from_whitelist" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  // 일반적으로는 회사 네트워크나 VPN 대역등을 넣습니다.
  cidr_blocks = [
    var.network_range_ssh_whitelist,
  ]

  security_group_id = aws_security_group.bastion_public.id

  description = "SSH Whitelisted"
}
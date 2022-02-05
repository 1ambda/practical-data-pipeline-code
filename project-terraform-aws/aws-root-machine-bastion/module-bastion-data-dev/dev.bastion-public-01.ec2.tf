resource "aws_instance" "bastion_public_01" {
  ami = var.bastion_ami

  lifecycle {
    create_before_destroy = false

    ignore_changes = [
      ami,
      user_data,
    ]
  }

  instance_type = "t3.small"
  subnet_id     = var.bastion_subnet_id

  vpc_security_group_ids = [var.bastion_sg_id]

  associate_public_ip_address = true
  monitoring = true

  key_name             = var.bastion_keypair
  iam_instance_profile = var.bastion_profile

  ebs_optimized = true
  root_block_device {
    volume_type           = "gp3"
    volume_size           = "100"
    delete_on_termination = false
  }

  user_data = data.template_cloudinit_config.bastion_user_data.rendered

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "${local.purpose_bastion_public}-01-${var.environment}"
  }

  volume_tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team

    Name = "${local.purpose_bastion_public}-01-${var.environment}"
  }
}

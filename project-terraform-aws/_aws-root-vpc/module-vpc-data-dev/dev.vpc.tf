module "vpc-data-development" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "vpc-data-${var.environment}"
  cidr = "10.10.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]

  /**
   *  실습 편의를 위해 Public Subnet 도 같은 VPC 내 추가합니다.
   */
  public_subnets  = ["10.10.128.0/19", "10.10.160.0/19", "10.10.192.0/19"]

  create_database_subnet_group = false

  enable_ipv6 = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options = false

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    Public = "true"
  }

  tags = {
    Owner       = "team-${var.team}"
    Environment = var.environment
  }

  vpc_tags = {
    Name = "vpc-${var.team}-${var.environment}"
  }
}

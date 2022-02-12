module "vpc-data-development" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "vpc-data-${var.environment}"
  cidr = "10.10.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.10.80.0/20", "10.10.96.0/20", "10.10.112.0/20"]

  /**
   *  실습 편의를 위해 Database Subnet 도 같은 VPC 내 추가합니다.
   */
  database_subnets = ["10.10.0.0/20", "10.10.32.0/20", "10.10.64.0/20"]
  create_database_subnet_group = true

  /**
   *  실습 편의를 위해 Public Subnet 도 같은 VPC 내 추가합니다.
   */
  public_subnets  = ["10.10.208.0/20", "10.10.224.0/20", "10.10.240.0/20"]


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

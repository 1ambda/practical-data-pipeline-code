output "vpc_id" {
  value = module.vpc-data-development.vpc_id
}

output "subnet_list_public" {
  value = module.vpc-data-development.public_subnets
}

output "subnet_list_private" {
  value = module.vpc-data-development.private_subnets
}


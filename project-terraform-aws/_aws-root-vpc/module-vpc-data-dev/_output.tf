output "vpc_id" {
  value = module.vpc-data-development.vpc_id
}

output "subnet_list_public" {
  value = module.vpc-data-development.public_subnets
}

output "subnet_list_private" {
  value = module.vpc-data-development.private_subnets
}

output "subnet_list_database" {
  value = module.vpc-data-development.database_subnets
}

output "subnet_name_database" {
  value = module.vpc-data-development.database_subnet_group_name
}

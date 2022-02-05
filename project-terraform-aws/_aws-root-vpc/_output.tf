output "vpc_id_data_dev" {
  value = module.module-vpc-data-dev.vpc_id
}

output "subnet_list_public_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_public
}

output "subnet_list_private_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_private
}

output "subnet_id_public_az_a_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_public[0]
}

output "subnet_id_public_az_b_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_public[1]
}

output "subnet_id_public_az_c_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_public[2]
}

output "subnet_id_private_az_a_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_private[0]
}

output "subnet_id_private_az_b_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_private[1]
}

output "subnet_id_private_az_c_data_dev" {
  value = module.module-vpc-data-dev.subnet_list_private[2]
}

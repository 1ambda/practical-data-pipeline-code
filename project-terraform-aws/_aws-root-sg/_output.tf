output "sg_id_bastion_public_data_dev" {
  value = module.module-sg-data-dev.sg_id_bastion_public_data_dev
}
output "sg_id_rds_hive_metastore_data_dev" {
  value = module.module-sg-data-dev.sg_id_rds_hive_metastore_data_dev
}

output "sg_id_emr_master_managed_data_dev" {
  value = module.module-sg-data-dev.sg_id_emr_master_managed_data_dev
}

output "sg_id_emr_master_additional_data_dev" {
  value = module.module-sg-data-dev.sg_id_emr_master_additional_data_dev
}

output "sg_id_emr_slave_managed_data_dev" {
  value = module.module-sg-data-dev.sg_id_emr_slave_managed_data_dev
}

output "sg_id_emr_slave_additional_data_dev" {
  value = module.module-sg-data-dev.sg_id_emr_slave_additional_data_dev
}

output "sg_id_emr_service_managed_data_dev" {
  value = module.module-sg-data-dev.sg_id_emr_service_managed_data_dev
}

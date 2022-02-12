output "sg_id_bastion_public_data_dev" {
  value = aws_security_group.bastion_public.id
}

output "sg_id_rds_hive_metastore_data_dev" {
  value = aws_security_group.rds_hive_metastore.id
}

output "sg_id_emr_master_managed_data_dev" {
  value = aws_security_group.emr_master_managed.id
}

output "sg_id_emr_master_additional_data_dev" {
  value = aws_security_group.emr_master_additional.id
}

output "sg_id_emr_slave_managed_data_dev" {
  value = aws_security_group.emr_slave_managed.id
}

output "sg_id_emr_slave_additional_data_dev" {
  value = aws_security_group.emr_slave_additional.id
}

output "sg_id_emr_service_managed_data_dev" {
  value = aws_security_group.emr_service_managed.id
}

output "sg_id_bastion_public_data_dev" {
  value = aws_security_group.bastion_public.id
}

output "sg_id_rds_hive_metastore_data_dev" {
  value = aws_security_group.rds_hive_metastore.id
}

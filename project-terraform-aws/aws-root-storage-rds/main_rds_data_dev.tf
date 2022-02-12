module "module-rds-data-dev" {
  source = "./module-rds-data-dev"

  environment = local.environment_development
  team = local.team_data

  vpc_id = data.terraform_remote_state.root_vpc.outputs.vpc_id_data_dev
  rds_hive_metastore_subnet_list = data.terraform_remote_state.root_vpc.outputs.subnet_list_database_data_dev
  rds_hive_metastore_subnet_group = data.terraform_remote_state.root_vpc.outputs.subnet_name_database_data_dev
  rds_hive_metastore_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_rds_hive_metastore_data_dev
}
module "module-emr-data-dev" {
  source = "./module-emr-data-dev"

  environment = local.environment_development
  team = local.team_data

  vpc_id = data.terraform_remote_state.root_vpc.outputs.vpc_id_data_dev
  emr_subnet = data.terraform_remote_state.root_vpc.outputs.subnet_id_private_az_c_data_dev /** AZ-c */

  emr_keypair = local.keypair_infra
  emr_profile_arn_instance = data.terraform_remote_state.root_iam.outputs.profile_arn_emr_instance
  emr_role_arn_cluster = data.terraform_remote_state.root_iam.outputs.role_arn_emr_cluster
  emr_role_arn_asg  = data.terraform_remote_state.root_iam.outputs.role_arn_emr_asg

  emr_master_managed_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_emr_master_managed_data_dev
  emr_master_additional_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_emr_master_additional_data_dev
  emr_slave_managed_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_emr_slave_managed_data_dev
  emr_slave_additional_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_emr_slave_additional_data_dev
  emr_service_managed_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_emr_service_managed_data_dev
}
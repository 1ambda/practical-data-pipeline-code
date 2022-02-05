module "module-bastion-data-dev" {
  source = "./module-bastion-data-dev"

  environment = local.environment_development
  team = local.team_data

  bastion_ami = data.aws_ami.amazon_linux_2.id
  bastion_profile = data.terraform_remote_state.root_iam.outputs.profile_id_bastion
  bastion_keypair = local.keypair_infra

  bastion_sg_id = data.terraform_remote_state.root_sg.outputs.sg_id_bastion_public_data_dev

  bastion_subnet_id = data.terraform_remote_state.root_vpc.outputs.subnet_id_public_az_a_data_dev
}
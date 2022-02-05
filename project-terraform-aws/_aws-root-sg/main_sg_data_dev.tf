module "module-sg-data-dev" {
  source = "./module-sg-data-dev"

  environment = local.environment_development
  team = local.team_data

  vpc_id = data.terraform_remote_state.root_vpc.outputs.vpc_id_data_dev
  network_range_ssh_whitelist = local.network_range_ssh_whitelist
}
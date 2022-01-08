module "module-vpc-data-dev" {
  source = "./module-vpc-data-dev"

  region = local.region_seoul
  environment = local.environment_development
  team = local.team_data
}
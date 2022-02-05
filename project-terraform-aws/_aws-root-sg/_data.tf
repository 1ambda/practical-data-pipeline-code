data "terraform_remote_state" "root_vpc" {
  backend = "local"

  config = {
    path = "../__tf_state/_aws-root-vpc/terraform.tfstate"
  }
}

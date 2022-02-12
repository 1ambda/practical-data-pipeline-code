data "terraform_remote_state" "root_iam" {
  backend = "local"

  config = {
    path = "../__tf_state/_aws-root-iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "root_vpc" {
  backend = "local"

  config = {
    path = "../__tf_state/_aws-root-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "root_sg" {
  backend = "local"

  config = {
    path = "../__tf_state/_aws-root-sg/terraform.tfstate"
  }
}
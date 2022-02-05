terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }

  /**
   * 테스팅 목적으로 Terraform Backend 를 사용하지 않습니다
   */

  backend "local" {
    path = "../__tf_state/_aws-root-iam/terraform.tfstate"
  }
}


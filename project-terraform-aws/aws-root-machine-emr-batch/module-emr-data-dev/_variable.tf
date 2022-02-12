variable "environment" {}
variable "team" {}


variable "emr_keypair" {}

variable "emr_profile_arn_instance" {}
variable "emr_role_arn_cluster" {}
variable "emr_role_arn_asg" {}

variable "vpc_id" {}
variable "emr_subnet" {}

variable "emr_master_managed_sg_id" {}
variable "emr_master_additional_sg_id" {}
variable "emr_slave_managed_sg_id" {}
variable "emr_slave_additional_sg_id" {}
variable "emr_service_managed_sg_id" {}


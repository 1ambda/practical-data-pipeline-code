output "profile_id_bastion" {
  value = module.module-iam-common.profile_id_bastion
}

output "profile_arn_emr_instance" {
  value = module.module-iam-common.profile_arn_emr_instance
}

output "role_arn_emr_cluster" {
  value = module.module-iam-common.role_arn_emr_cluster
}

output "role_arn_emr_asg" {
  value = module.module-iam-common.role_arn_emr_asg
}

output "profile_id_bastion" {
  value = aws_iam_instance_profile.bastion.id
}

output "profile_arn_emr_instance" {
  value = aws_iam_instance_profile.emr_instance.arn
}

output "role_arn_emr_cluster" {
  value = aws_iam_role.emr_cluster.arn
}

output "role_arn_emr_asg" {
  value = aws_iam_role.emr_asg.arn
}

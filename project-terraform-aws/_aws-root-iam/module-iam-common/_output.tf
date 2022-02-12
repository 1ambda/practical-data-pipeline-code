output "profile_id_bastion" {
  value = aws_iam_instance_profile.bastion.id
}

output "profile_arn_emr_instance" {
  value = aws_iam_instance_profile.emr_instance.arn
}

output "profile_arn_emr_cluster" {
  value = aws_iam_instance_profile.emr_cluster.arn
}

output "profile_arn_emr_asg" {
  value = aws_iam_instance_profile.emr_asg.arn
}

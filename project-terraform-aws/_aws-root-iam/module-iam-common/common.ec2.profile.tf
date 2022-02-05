locals {
  instance_purpose_bastion = "ec2-bastion"
}

#
# Role, Instance Profile
#

resource "aws_iam_role" "bastion" {
  name = "${lower(var.environment)}-${local.instance_purpose_bastion}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${lower(var.environment)}-${local.instance_purpose_bastion}"
  role = aws_iam_role.bastion.name
}

#
# Policy Attachments
#

resource "aws_iam_role_policy_attachment" "bastion_cloudwatch" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_monitoring.arn
}

resource "aws_iam_role_policy_attachment" "bastion_operation_volume" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.ec2_operation_volume.arn
}

resource "aws_iam_role_policy_attachment" "bastion_access_s3_full" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.ec2_access_s3_full.arn
}

resource "aws_iam_role_policy_attachment" "bastion_session_manager" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.ec2_session_manager.arn
}

locals {
  instance_purpose_basic = "ec2-basic"
}

#
# Role, Instance Profile
#

resource "aws_iam_role" "basic" {
  name = "${lower(var.environment)}-${local.instance_purpose_basic}"

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

resource "aws_iam_instance_profile" "basic" {
  name = "${lower(var.environment)}-${local.instance_purpose_basic}"
  role = aws_iam_role.basic.name
}

#
# Policy Attachments
#

resource "aws_iam_role_policy_attachment" "basic_cloudwatch" {
  role       = aws_iam_role.basic.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_monitoring.arn
}

resource "aws_iam_role_policy_attachment" "basic_operation_volume" {
  role       = aws_iam_role.basic.name
  policy_arn = aws_iam_policy.ec2_operation_volume.arn
}
locals {
  instance_purpose_emr_cluster         = "emr-cluster"
  instance_purpose_emr_instance        = "emr-instance"
  instance_purpose_emr_asg             = "emr-asg"
}

#
# Role, Instance Profile
# - https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles-defaultroles.html
#

// data "aws_iam_role" "iam_role_emr_cluster_default" {
//   name = "EMR_DefaultRole"
// }
//
// data "aws_iam_role" "iam_role_emr_instance_default" {
//   name = "EMR_EC2_DefaultRole"
// }
//
// data "aws_iam_role" "iam_role_emr_asg_default" {
//   name = "EMR_AutoScaling_DefaultRole"
// }

resource "aws_iam_role" "emr_cluster" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_cluster}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "emr_instance" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_instance}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
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

resource "aws_iam_role" "emr_asg" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_asg}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "elasticmapreduce.amazonaws.com",
          "application-autoscaling.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "emr_cluster" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_cluster}"
  role = aws_iam_role.emr_cluster.name
}

resource "aws_iam_instance_profile" "emr_instance" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_instance}"
  role = aws_iam_role.emr_instance.name
}

resource "aws_iam_instance_profile" "emr_asg" {
  name = "${lower(var.environment)}-${local.instance_purpose_emr_asg}"
  role = aws_iam_role.emr_asg.name
}

#
# Policy Attachments: CLUSTER
#

resource "aws_iam_role_policy_attachment" "emr_cluster_basic" {
  role       = aws_iam_role.emr_cluster.name
  policy_arn = aws_iam_policy.emr_cluster.arn
}
#
# Policy Attachments: INSTANCE (EC2)
#

resource "aws_iam_role_policy_attachment" "emr_instance_basic" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = aws_iam_policy.emr_instance.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_cloudwatch" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_monitoring.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_operation_tags" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = aws_iam_policy.ec2_operation_tags.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_operation_private_ip" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = aws_iam_policy.ec2_operation_private_ip.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_dynamo_full" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = data.aws_iam_policy.managed_dynamo_full.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_kinesis_stream_full" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = data.aws_iam_policy.managed_kinesis_stream_full.arn
}

resource "aws_iam_role_policy_attachment" "emr_instance_session_manager" {
  role       = aws_iam_role.emr_instance.name
  policy_arn = aws_iam_policy.ec2_session_manager.arn
}

#
# Policy Attachments: ASG
#

resource "aws_iam_role_policy_attachment" "emr_asg_basic" {
  role       = aws_iam_role.emr_asg.name
  policy_arn = aws_iam_policy.emr_asg.arn
}

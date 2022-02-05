data "aws_iam_policy" "managed_dynamo_full" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "managed_kinesis_stream_full" {
  arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

data "aws_iam_policy" "managed_data_scientist" {
  arn = "arn:aws:iam::aws:policy/job-function/DataScientist"
}

data "aws_iam_policy" "managed_s3_full" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

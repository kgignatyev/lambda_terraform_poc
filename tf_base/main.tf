terraform {

}

provider "aws" {
  region = "us-west-2"
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_kgi"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

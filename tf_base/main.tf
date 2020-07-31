terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "kgi-terraform-state"
    key = "kgi_poc"
  }

}

provider "aws" {
  region = "us-west-2"
}




resource "aws_vpc" "poc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "POC"
  }

}

resource "aws_subnet" "private1" {
  cidr_block = "10.10.10.0/24"
  vpc_id = aws_vpc.poc.id
  tags = {
    Name = "private1"
    Use = "lambdas"
  }
}

resource "aws_subnet" "private2" {
  cidr_block = "10.10.20.0/24"
  vpc_id = aws_vpc.poc.id
  tags = {
    Name = "private2"
    Use = "lambda1"
    Use = "lambda2"
  }
}

resource "aws_security_group" "https" {
  vpc_id = aws_vpc.poc.id
  tags = {
    Name = "https"
    Use = "lambdas"
  }

  egress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }
}


resource "aws_security_group" "lambda1" {
  vpc_id = aws_vpc.poc.id
  tags = {
    Name = "lambda1"
    Use = "lambda1"
  }

  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
}

resource "aws_security_group" "lambda2" {
  vpc_id = aws_vpc.poc.id
  tags = {
    Name = "lambda2"
    Use = "lambda2"
  }

  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
}


resource "aws_iam_policy" "for_lambda" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
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

resource "aws_iam_policy_attachment" "for_lambdas" {
  roles = [aws_iam_role.iam_for_lambda.id]

  policy_arn = aws_iam_policy.for_lambda.arn
  name = "for_lambdas"
}

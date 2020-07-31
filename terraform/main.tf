terraform {

}

provider "aws" {
  region = "us-west-2"
}


//set the actual role name
data "aws_iam_role" "lambda_role" {
  name = "iam_for_lambda_kgi"
}

data "aws_vpc" "poc" {
  tags = {
    Name = "POC"
  }
}


data "aws_subnet_ids" "poc_subnets" {
  vpc_id = data.aws_vpc.poc.id
}

data "aws_security_groups" "for_lambda1" {
  tags = {
    Use = "lambda1"
  }
}

data "aws_security_groups" "for_lambda2" {
  tags = {
    Use = "lambda2"
  }
}


resource "null_resource" "lambda1build" {


  triggers = {
    main         = base64sha256(file("../src/lambda1/main.py"))
    requirements = base64sha256(file("../src/lambda1/requirements.txt"))
  }

  provisioner "local-exec" {
    command = "../utils/build_py_lambda.sh ${path.module}/../src/lambda1 ${path.module}/../build/lambda1"
  }

}


resource "null_resource" "lambda2build" {


  triggers = {
    main         = base64sha256(file("../src/lambda1/main.py"))
    requirements = base64sha256(file("../src/lambda1/requirements.txt"))
  }

  provisioner "local-exec" {
    command = "../utils/build_py_lambda.sh ${path.module}/../src/lambda2 ${path.module}/../build/lambda2"
  }

}

data "archive_file" "lambda1source" {
  type        = "zip"
  source_dir  = "${path.module}/../build/lambda1"
  output_path = "${path.module}/../build/lambda1.zip"
  depends_on = [null_resource.lambda1build]
}


data "archive_file" "lambda2source" {
  type        = "zip"
  source_dir  = "${path.module}/../build/lambda2"
  output_path = "${path.module}/../build/lambda2.zip"
  depends_on = [null_resource.lambda1build]
}


resource "aws_lambda_function" "test_lambda" {

  depends_on = [data.archive_file.lambda1source]

  filename      = data.archive_file.lambda1source.output_path
  function_name = "kgi_test"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda1source.output_base64sha256

  runtime = "python3.7"

  vpc_config {
    security_group_ids = data.aws_security_groups.for_lambda1.ids
    subnet_ids = data.aws_subnet_ids.poc_subnets.ids
  }

  environment {
    variables = {
      foo = "bar"
    }
  }
}


resource "aws_lambda_function" "test_lambda2" {

  depends_on = [data.archive_file.lambda2source]

  filename      = data.archive_file.lambda2source.output_path
  function_name = "kgi_test_2"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda2source.output_base64sha256

  runtime = "python3.7"

  vpc_config {
    security_group_ids = data.aws_security_groups.for_lambda2.ids
    subnet_ids = data.aws_subnet_ids.poc_subnets.ids
  }

  environment {
    variables = {
      foo = "bar"
    }
  }
}

terraform {

}

provider "aws" {
  region = "us-west-2"
}


//set the actual role name
data "aws_iam_role" "lambda_role" {
  name = "iam_for_lambda_kgi"
}


resource "null_resource" "pip" {


  triggers = {
    main         = base64sha256(file("../src/lambda1/main.py"))
    requirements = base64sha256(file("../src/lambda1/requirements.txt"))
  }

  provisioner "local-exec" {
    command = "../utils/build_py_lambda.sh ${path.module}/../src/lambda1 ${path.module}/../build/lambda1"
  }

}

data "archive_file" "lambda1source" {
  type        = "zip"
  source_dir  = "${path.module}/../build/lambda1"
  output_path = "${path.module}/../build/lambda1.zip"
  depends_on = [null_resource.pip]
}


resource "aws_lambda_function" "test_lambda" {

  depends_on = [data.archive_file.lambda1source]

  filename      = data.archive_file.lambda1source.output_path
  function_name = "kgi_test"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda1source.output_base64sha256

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

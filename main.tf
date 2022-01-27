terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  #  shared_credentials_file = "/Users/wuyefeng/.aws/credentials"
  profile = "default"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/hello.py"
  output_path = "${path.module}/hello.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/hello.zip"
  function_name    = "hello_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "hello.lambda_handler"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  runtime          = "python3.8"
}

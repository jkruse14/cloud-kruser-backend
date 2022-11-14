terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

resource "aws_lambda_function" "lambdas" {
  for_each         = var.lambdas
  role             = each.value.role_arn
  filename         = each.value.filename
  function_name    = "${var.name_prefix}-${each.value.function_name}"
  handler          = each.value.handler
  source_code_hash = filebase64sha256(each.value.filename)
  runtime          = "nodejs16.x"
  memory_size      = 128
  timeout          = 3
  architectures    = ["arm64"]
  environment {
    variables = each.value.environment_variables
  }
  layers = var.common_layers
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "cloud-kruser"
    }
  }
}
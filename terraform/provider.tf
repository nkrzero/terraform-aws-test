# Terraform version + required providers
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Uses the AWS CLI profile "test" (see docs/03-aws-cli-profiles.md)
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

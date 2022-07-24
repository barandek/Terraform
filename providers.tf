# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.

# Declare aws providers is required so Terraform install and use it
terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.22"
    }
  }  
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}

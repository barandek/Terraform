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
  backend "s3" {
    bucket = "terraform-s3-bucket-bnycz"
    key = "dev/wordpress/terraform.tfstate"
    region = "eu-central-1"

    # State Locking
    dynamodb_table = "dev-wordpress-bnycz"
  }  
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}

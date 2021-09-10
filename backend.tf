# Here we create our backend in s3
# Profile is created with aws configure --profile command
# Key is state file filename
# Bucket was created using aws s3cli command
# aws s3api create-bucket --bucket my-bucket

terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "us-east-1"
    profile = "bnycz"
    key     = "terraform_state_file"
    bucket  = "terraformstateb121"
  }
}



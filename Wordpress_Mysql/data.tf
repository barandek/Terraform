# Use this data source to get info about account terraform uses
data "aws_caller_identity" "current" {}

# Find Availability Zones
data "aws_availability_zones" "az_available" {
    state = "available"
# If the Region is enabled by default, the output includes the following:
# "OptInStatus": "opt-in-not-required"
    filter {
      name = "opt-in-status"
      values = ["opt-in-not-required"]
    }
}

data "aws_ami" "ec2_most_recent_linux" {
    most_recent = true
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "name"
        values = ["amzn2-ami-kernel*-x86_64-gp2"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    owners = ["amazon"]
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "terraform-s3-bucket-bnycz"
        key = "dev/vpc/terraform.tfstate"
        region = var.aws_region
    }

}
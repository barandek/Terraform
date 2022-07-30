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

data "terraform_remote_state" "ec2_with_vpc" {
    backend = "s3"
    config = {
        bucket = "terraform-s3-bucket-bnycz"
        key = "dev/vpc/terraform.tfstate"
        region = var.aws_region
    }

}
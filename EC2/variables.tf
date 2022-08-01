variable "aws_region" {
  type = string
  default = "eu-central-1"
  description = "AWS region in which resources will be created"
}

variable "instance_keypair" {
  type = string
  default = "ec2_test_key"
  description = "AWS EC2 Key Pair name associated with EC2 instance"
}

variable "instance_type_map" {
  description = "EC2 Instance Type - map for different environments"
  type = map(string)
  default = {
    "dev" = "t3.micro"
    "test" = "t2.micro"
    "prod" = "t2.micro"
  }
}

variable "ha_az" {
  description = "Number of AZ to use to provide HA of instances"
  type = number
  default = 2
}
variable "vpc_cidr" {
  type = string
  default = "172.32.0.0/24"
  description = "This CIDR contains addresses used to create VPC"
}

variable "public_subnet_cidr" {
  type = string
  default = "172.32.0.0/25"
  description = "This CIDR contains addresses used to create VPC public subnet"
}

variable "private_subnet_cidr" {
  type = string
  default = "172.32.0.128/25"
  description = "This CIDR contains addresses used to create VPC private subnet"
}

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
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

variable "instance_type" {
  description = "EC2 Instance Type - map for different environments"
  type = string
  default = "t3.micro"
}

variable "ha_az" {
  description = "Number of AZ to use to provide HA of instances"
  type = number
  default = 2
}

variable "vpc_cidr" {
  type = string
  default = "172.32.0.0/23"
  description = "This CIDR contains addresses used to create VPC"
}

variable "public_subnets_cidr" {
  type = list(string)
  default = ["172.32.0.0/25", "172.32.1.0/25"]
  description = "This CIDR contains addresses used to create VPC public subnet"
}

variable "private_subnets_cidr" {
  type = list(string)
  default = ["172.32.0.128/25", "172.32.1.128/25"]
  description = "This CIDR contains addresses used to create VPC private subnet"
}
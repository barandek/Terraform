variable "vpc_cidr" {
  type = string
  default = "172.32.0.0/23"
  description = "This CIDR contains addresses used to create VPC"
}

variable "public_subnets_cidr" {
  type = list(string)
  description = "This CIDR contains addresses used to create VPC public subnet"
}

variable "private_subnets_cidr" {
  type = list(string)
  description = "This CIDR contains addresses used to create VPC private subnet"
}

variable "aws_region" {
  type = string
  default = "eu-central-1"
  description = "AWS region in which resources will be created"
}

variable "ha_az" {
  description = "Number of AZ to use to provide HA of instances"
  type = number
  default = 2
}

variable "create_nat_gateway" {
  description = "Switch to create NAT gateway in private subnet"
  type = bool
  default = true
}
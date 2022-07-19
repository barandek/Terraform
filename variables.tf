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
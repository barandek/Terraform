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

variable "site_domain" {
  type        = string
  description = "The site domain name to configure (without any subdomains such as 'www')"
  default = "testdomain"
}

variable "site_prefix" {
  type        = string
  description = "The subdomain prefix of the website domain. E.g. www"
  default     = "www"
}
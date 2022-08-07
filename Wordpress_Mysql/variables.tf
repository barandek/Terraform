variable "aws_region" {
  type = string
  default = "eu-central-1"
  description = "AWS region in which resources will be created"
}

variable "ec2_custom_ssh_keypair_name" {
  type = string
  default = null
  description = "AWS EC2 Key Pair name associated with EC2 instance, set to null if you want to generate new one"
}

variable "base_path" {
  description = "Base path where to copy ssh keys"
  default = "~/.ssh"
}

variable "instance_type" {
  description = "EC2 Instance Type - map for different environments"
  type = string
  default = "t3.micro"
}

variable "rds_instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "rds_multiaz" {
  type = bool
  default = false 
}

variable "db_name" {
  type = string
  default = "Wordpress_MYSQL_"
}

variable "bitnami_wordpress_ami_id" {
  type = string
  default = null
}

variable "use_asg_spot" {
  description = "Set to true if you want to create ASG with Launch Template"
  type = bool
  default = false
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

variable "ec2_public_subnet" {
  type = bool
  default = false
}

variable "ec2_numInstances" {
  type = number
  default = null
}

variable "ec2_EBSvolumeSize" {
  type = number
  default = 10
}

variable "wordpress_ssl_acm_certificate_arn" {
  description = "Load Balancer SSL certificate arn from ACM" 
  type = string
  default = null
}
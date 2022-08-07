# AWS Setup
aws_region = "eu-central-1"

# High Availability Zones
ha_az = 2

# VPC
public_subnets_cidr = ["172.32.0.0/25", "172.32.1.0/25"]
private_subnets_cidr = ["172.32.0.128/25", "172.32.1.128/25"]
vpc_cidr = "172.32.0.0/23"
create_nat_gateway = true

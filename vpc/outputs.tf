output "vpc_id" {
    description = "The ID of the VPC"
    value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
    description = "The CIDR block of the VPC"
    value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
    description = "List of ID's of private subnets"
    value = module.vpc.private_subnets
}

output "public_subnets" {
    description = "List of ID's of public subnets"
    value = module.vpc.public_subnets
}

output "azs" {
    description = "List of AZ available"
    value = data.aws_availability_zones.az_available.names
}

output "sliced_az" {
    description = "List of AZ selected for High Availability"
    value = local.az_ha
}

output "sg_ssh_https" {
    value = aws_security_group.sg_ssh_https.id
}
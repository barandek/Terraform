# Use of VPC module
# Module which creates VPC resources on AWS

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.14.2"
    # VPC Basic Details
    name = "VPC-${local.owner}"
    cidr = var.vpc_cidr
    azs = local.az_filtered
    private_subnets = var.private_subnets_cidr
    #private_subnets = ["${cidrsubnet(var.vpc_cidr,8,each.key)}"]
    private_subnet_tags = {
        Name = "Private_Subnet-${local.owner}"
    }
    public_subnets = var.public_subnets_cidr
    #public_subnets = ["${cidrsubnet(var.vpc_cidr,8,each.key)}"]
    public_subnet_tags = {
        Name = "Public_Subnet-${local.owner}"
    }
    # NAT Gateways 
    enable_nat_gateway = true
    # Create NAT gateway in all AZ's
    single_nat_gateway = false
    # VPC DNS setup
    enable_dns_hostnames = true
    enable_dns_support = true
    # Add common tags to all resources
    tags = local.common_tags
    # VPC Tags
    vpc_tags = {
        Name = "${local.environment}-VPC-${local.owner}"
    }
}

resource "aws_security_group" "sg_ssh_https" { 
    vpc_id = module.vpc.vpc_id
    name = "SG for SSH"
    description = "SG for VPC - allow SSH/HTTPS connections"
    tags = merge(
        local.common_tags,
        {
            Name = "SG-ssh_https-${local.exercise_name}"
        },
    )
    dynamic "ingress" {
        for_each = local.ingress_rules
        content {
            description = ingress.value.description
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]            
        }
    }
    egress {
        description = "Internet access to anywhere"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
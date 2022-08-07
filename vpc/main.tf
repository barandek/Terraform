# Use of VPC module
# Module which creates VPC resources on AWS

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.14.2"
    # VPC Basic Details
    name = "VPC-${local.environment}-${local.name}"
    cidr = var.vpc_cidr
    azs = "${data.aws_availability_zones.az_available.names}"
    private_subnets = slice(var.private_subnets_cidr, 0, var.ha_az)
    #private_subnets = ["${cidrsubnet(var.vpc_cidr,8,each.key)}"]
    private_subnet_tags = {
        Name = "Private_Subnet-${local.name}"
        Owner = "${local.owner}"
    }
    public_subnets = slice(var.public_subnets_cidr, 0, var.ha_az)
    #public_subnets = ["${cidrsubnet(var.vpc_cidr,8,each.key)}"]
    public_subnet_tags = {
        Name = "Public_Subnet-${local.name}"
        Owner = "${local.owner}"
    }
    # NAT Gateways 
    enable_nat_gateway = var.create_nat_gateway == true ? true : false
    single_nat_gateway = false
    one_nat_gateway_per_az = false

    # VPC DNS setup
    enable_dns_hostnames = true
    enable_dns_support = true

    # Add common tags to NACL, RT, SG
    manage_default_network_acl = true
    default_network_acl_tags   = { 
        Name = "${local.name}-default" 
    }
    manage_default_route_table = true
    default_route_table_tags   = { 
        Name = "${local.name}-default" 
    }
    manage_default_security_group = true
    default_security_group_tags   = { 
        Name = "${local.name}-default" 
    } 

    # Add common tags to all resources
    tags = local.common_tags    
}

resource "aws_security_group" "sg_ssh_https" { 
    vpc_id = module.vpc.vpc_id
    name = "SG for SSH"
    description = "SG for VPC - allow SSH/HTTPS connections"
    tags = merge(
        local.common_tags,
        {
            Name = "SG-ssh_https-${local.name}"
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
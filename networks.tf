resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr
    # Enable DNS hostnames/resolution in VPC
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = merge(
        local.common_tags,
        {
            Name = "VPC-${local.owner}"
        },
    )
}

resource "aws_main_route_table_association" "main_route_table" {
  vpc_id         = aws_vpc.default.id
  route_table_id = aws_route_table.route.id
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.default.id
    map_public_ip_on_launch = true
    cidr_block = var.public_subnet_cidr
    tags = merge(
        local.common_tags,
        {
            Name = "Public_Subnet-${local.owner}"
        },
    )
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.default.id
    route {
        gateway_id = aws_internet_gateway.default.id
        cidr_block = "0.0.0.0/0"
    }
    tags = merge(
        local.common_tags,
        {
            Name = "RouteTable-IGW-${local.owner}"
        },
    )
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
    tags = local.common_tags
}

resource "aws_security_group" "sg_ssh" {
    vpc_id = aws_vpc.default.id
    name = "SG for SSH"
    description = "SG for VPC - allow SSH connections"
    tags = merge(
        local.common_tags,
        {
            Name = "SG-ssh-${local.exercise_name}"
        },
    )
    # SSH access from anywhere
    ingress {
        description = "SSH access from anywhere"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Internet access to anywhere"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sg_http" {
    vpc_id = aws_vpc.default.id
    name = "SG for HTTP"
    description = "SG for VPC - allow HTTP/HTTPS connections"
    tags = merge(
        local.common_tags,
        {
            Name = "SG-http-${local.exercise_name}"
        },
    )
    ingress {
        description = "HTTP access from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTPs access from anywhere"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
    egress {
        description = "Internet access to anywhere"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
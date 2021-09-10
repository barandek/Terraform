data "aws_caller_identity" "aws_identity" {}

# Create VPC in us-east-1 called vpc_master and tag master-vpc-jenkins
# aws.region-master is alias from providers us-east-1

resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }
}

# Create VPC on worker provider
resource "aws_vpc" "vpc_worker" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

# Create Internet Gateway IGW in us-east-1
resource "aws_internet_gateway" "igw-master" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

# Create Internet Gateway IGW in us-east-2
resource "aws_internet_gateway" "igw-worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
}

# Get all available AZ in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

# Get all available AZ in VPC for worker region
data "aws_availability_zones" "azs_worker" {
  provider = aws.region-master
  state    = "available"
}

# Create subnet #1 in us-east-1
# Takes the element of aws_availability_zones above and takes first element - zero index
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

# Create subnet #2 in us-east-1
# Takes the element of aws_availability_zones above and takes second element - first index
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

# Create subnet in us-east-2
resource "aws_subnet" "subnet_1_worker" {
  provider          = aws.region-worker
  availability_zone = element(data.aws_availability_zones.azs_worker.names, 0)
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.1.0/24"
}

# Initiate Peering connection requests from master to worker
resource "aws_vpc_peering_connection" "master-worker" {
  peer_owner_id = data.aws_caller_identity.aws_identity.account_id
  peer_vpc_id   = aws_vpc.vpc_worker.id
  vpc_id        = aws_vpc.vpc_master.id
  peer_region   = var.region-worker
}

resource "aws_vpc_peering_connection_accepter" "worker-master" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.master-worker.id
  auto_accept               = true
}

# Create routing tables to enable communication between two VPC
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-master.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.master-worker.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RouteTable"
  }
}

# Overwrite default route table of VPC master using route above named "internet_route"
resource "aws_main_route_table_association" "set-master-default-rt" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

# Create routing tables to enable communication between two VPC
resource "aws_route_table" "internet_route_worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-worker.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.master-worker.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RouteTable"
  }
}

# Overwrite default route table of VPC worker using route table named "internet_route_worker"
resource "aws_main_route_table_association" "set-worker-default-rt" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.internet_route_worker.id
}


locals {
    # default VPC security group - dynamic block (ingress)
    ingress_rules = [{
        port = 443
        description = "HTTPS"
    },
    {
        port = 80
        description = "HTTP"
    },
    {
        port = 22
        description = "SSH"
    }
    ]
}

locals {
    owner = data.aws_caller_identity.current.user_id
    name = "vpc-poc"
    environment = "staging"
    common_tags = {
        Owner = local.owner
        Environment = local.environment
    }
}

locals {
    az_ha = slice(data.aws_availability_zones.az_available.names, 0, var.ha_az)
}

locals {
  cidrsubnet = {

  }
}
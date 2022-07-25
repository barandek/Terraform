locals {
    owner = data.aws_caller_identity.current.user_id
    exercise_name = "EC2_creation"
    environment = "dev"
}

locals {
    common_tags = {
        Owner = local.owner
        Exercise = local.exercise_name
        Environment = local.environment
    }
}

locals {
    az_filtered = "${keys({
        for key, values
        in data.aws_ec2_instance_type_offerings.instance_type_check: 
        key => values.instance_types if length(values.instance_types) != 0
    })}"
}

locals {
    # create dynamic block for ingress security groups
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
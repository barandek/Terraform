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
    instance_type_check = "${keys({
        for key, values
        in data.aws_ec2_instance_type_offerings.instance_type_check: 
        key => values.instance_types if length(values.instance_types) != 0
    })}"
}
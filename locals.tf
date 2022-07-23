locals {
    owner = data.aws_caller_identity.current.user_id
    exercise_name = "EC2_creation"
    environment = "test"
}

locals {
    common_tags = {
        Owner = local.owner
        Exercise = local.exercise_name
        Environment = local.environment
    }
}
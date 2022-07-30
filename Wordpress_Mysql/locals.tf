locals {
  name   = "complete-mysql"
  tags = {
    Owner       = "rds_test"
    Environment = "dev"
  }
}

locals {
    owner = data.aws_caller_identity.current.user_id
    exercise_name = "EC2-creation"
    environment = "dev"
}

locals {
    common_tags = {
        Owner = local.owner
        Exercise = local.exercise_name
        Environment = local.environment
    }
}
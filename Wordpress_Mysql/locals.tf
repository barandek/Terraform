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
    site_name = "test_sitename"
}

locals {
    common_tags = {
        Owner = local.owner
        Exercise = local.exercise_name
        Environment = local.environment
    }
}

# EC2 instance setup
locals {
  az_name = "eu-central-1a"
}
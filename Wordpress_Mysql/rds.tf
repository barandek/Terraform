resource "random_password" "mysql_password" {
  length           = 16
  special          = true
}

# Provides an RDS DB subnet group resource.
resource "aws_db_subnet_group" "mysql_db_subnets" {
  name       = "mysql db subnet"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = var.rds_instance_class
  storage_type         = "gp2"
  db_subnet_group_name = aws_db_subnet_group.mysql_db_subnets.name
  db_name              = local.db_name
  username             = "admin"
  password             = random_password.mysql_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  apply_immediately = false
  multi_az = var.rds_multiaz
}

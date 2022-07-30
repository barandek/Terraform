resource "aws_db_instance" "default" {
  #count = var.ha_az
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  #availability_zone = data.terraform_remote_state.ec2_with_vpc.outputs.az_filtered[count.index]
  apply_immediately = false
  multi_az = true
}

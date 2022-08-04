# RDS
rds_instance_class = "db.t3.micro"
rds_multiaz = false

# ASG with Spot Instances
use_asg_spot = false

# High Availability setup
ha_az = 1

# EC2 setup
ec2_public_subnet = true
custom_instance_keypair_name = "bnycz-rsa"
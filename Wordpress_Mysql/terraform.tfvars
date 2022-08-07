# RDS
rds_instance_class = "db.t3.micro"
rds_multiaz = false

# ASG with Spot Instances
use_asg_spot = false

# Load Balancer SSL certificate arn
# wordpress_ssl_acm_certificate_arn = "TO PROVIDE"

# EC2 setup
ec2_public_subnet = true
ec2_custom_ssh_keypair_name = "bnycz-rsa"
ec2_numInstances = 3
ec2_EBSvolumeSize = 10
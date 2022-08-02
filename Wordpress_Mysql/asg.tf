# SSH KEYS
resource "tls_private_key" "generate_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_ssh" {
  key_name   = "wordpress-ssh"
  public_key = tls_private_key.generate_ssh.public_key_openssh
}

# Launch Template for ASG
resource "aws_launch_template" "linux_ami" {
  name_prefix   = "wordpress"
  image_id = data.aws_ami.ec2_most_recent_linux.id
  key_name = aws_key_pair.generated_key_ssh.key_name
  # TBD vpc_security_group_ids = ["TBD"]

  # TBD user_data = filebase64("${path.module}/example.sh")
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = local.common_tags
  }
  #iam_instance_profile = "TBD"
}

# ASG with Spot instances and Capacity Rebalance
resource "aws_autoscaling_group" "example" {
  capacity_rebalance  = true
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  default_cooldown = 300 
  vpc_zone_identifier = [data.terraform_remote_state.vpc.outputs.public_subnets[0]]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools = 3
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.linux_ami.id
        version = "$Latest"
      }

      override {
        instance_type     = "t2.micro"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t3.micro"
        weighted_capacity = "1"
      }
    }
  }
}

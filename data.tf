# Find the latest available AMI for EC2 Amazon Linux 2

data "aws_ami" "ec2_most_recent_linux" {
    most_recent = true
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "name"
        values = ["amzn2-ami-kernel*-x86_64-gp2"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    owners = ["amazon"]
}

# Use this data source to get info about account terraform uses
data "aws_caller_identity" "current" {}
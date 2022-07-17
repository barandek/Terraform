# Find the latest available AMI for EC2

data "aws_ami" "ec2_most_recent_linux" {
    most_recent = true
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "Virtualization"
        values = ["hvm"]
    }
    owners = ["amazon"]
}
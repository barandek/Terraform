# Output the latest AMI image
output "ec2_latest_ami" {
    value = data.aws_ami.ec2_most_recent_linux.id
}
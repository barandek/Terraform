output "ec2_latest_ami" {
    value = data.aws_ami.ec2_most_recent_linux.id
    description = "Output the latest AMI image"
}

output "caller_user" {
    value = data.aws_caller_identity.current.user_id
    description = "Username/e-mail identified as current user"
}

output "public_ip_ec2" {
    value = aws_instance.t2_micro.public_ip
    description = "Public IP address of the EC2 instance created"
}
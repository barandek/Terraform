output "ec2_latest_ami" {
    value = data.aws_ami.ec2_most_recent_linux.id
    description = "Output the latest AMI image"
}

output "caller_user" {
    value = data.aws_caller_identity.current.user_id
    description = "Username/e-mail identified as current user"
}
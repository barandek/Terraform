output "ec2_latest_ami" {
    value = data.aws_ami.ec2_most_recent_linux.id
    description = "Output the latest AMI image"
}

output "caller_user" {
    value = data.aws_caller_identity.current.user_id
    description = "Username/e-mail identified as current user"
}

output "public_dns" {
    # For Loop with MAP
    value = {for instance in aws_instance.ins1: instance.id => instance.public_dns}
    description = "Public DNS address of the EC2 instance created"
}

output "az_filtered" {
    value = local.az_filtered
    description = "List of AZ that assure instance type for environment"
}


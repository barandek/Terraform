# And here's the result! We have a dynamic list of maps. I'm just outputting it here, but we should
# be able to take the same value and set it as the input to aws_lb's subnet_mapping param.
output "remote_state_example" {
    value = data.terraform_remote_state.ec2_with_vpc.outputs.public_dns
}
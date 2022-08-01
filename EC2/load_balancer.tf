resource "aws_lb" "loadbalancer-1" {
    name = "test-${local.environment}-${local.exercise_name}"
    internal = false
    load_balancer_type = "application"
    security_groups = [data.terraform_remote_state.vpc.outputs.sg_ssh_https]
    subnets = data.terraform_remote_state.vpc.outputs.private_subnets
}
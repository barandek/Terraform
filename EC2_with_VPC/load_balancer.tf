resource "aws_lb" "loadbalancer-1" {
    name = "test-${local.environment}-${local.exercise_name}"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.sg_ssh_https.id]
    subnets = module.vpc.private_subnets
}
# Create internet facing Frontend ALB
resource "aws_lb" "frontend-lb" {
  name = "Wordpress-Frontend-LB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_alb.id]
  subnets = var.ec2_public_subnet == true ? data.terraform_remote_state.vpc.outputs.public_subnets : data.terraform_remote_state.vpc.outputs.private_subnets
  tags = {
    "Environment" = "${local.environment}"
  }
}

# ALB Configuration for Frontend Target Group
resource "aws_lb_listener" "alb-frontend-listener" {
    load_balancer_arn = aws_lb.frontend-lb.arn
    port = 80
    protocol = "HTTP"
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.wordpress-frontend-tg.arn
    }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.frontend-lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.wordpress_ssl_acm_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-frontend-tg.arn
  }
}

# Target Group
resource "aws_lb_target_group" "wordpress-frontend-tg" {
  name = "wordpress-frontend-tg"
  port = 80
  target_type = "instance"
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

# Register instances and containers with an ALB Target Group
resource "aws_lb_target_group_attachment" "wordpress-tg_attach" {
    count = var.use_asg_spot == true ? 0 : var.ec2_numInstances
    target_group_arn = aws_lb_target_group.wordpress-frontend-tg.arn
    target_id        = aws_instance.ins1[count.index].id
}

resource "aws_autoscaling_attachment" "wordpress-asg_attach" {
    count = var.use_asg_spot == true ? 1 : 0
    autoscaling_group_name = aws_autoscaling_group.asg_wordpress[count.index].name
    lb_target_group_arn    = aws_lb_target_group.wordpress-frontend-tg.arn
}
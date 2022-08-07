resource "aws_security_group" "mysql_sgroup" {
  name        = "mysql_sg"
  description = "security group for RDS mysql"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "sg_ingress_3306" {
  security_group_id        = aws_security_group.mysql_sgroup.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.mysql_sgroup.id
  description              = "Ingress mySQL port"
}

resource "aws_security_group" "sg_alb" { 
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    name = "wordpress_alb_sg"
    description = "ALB Internet-Facing for Wordpress security group"
    tags = merge(
        local.common_tags,
        {
            Name = "SG-wordpress-alb-${local.site_name}"
        },
    )
    dynamic "ingress" {
        for_each = local.alb_ingress_rules
        content {
            description = ingress.value.description
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]            
        }
    }
    egress {
        description = "Internet access to anywhere"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
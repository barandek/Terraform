resource "aws_security_group" "mysql_sgroup" {
  name        = "${var.site_domain}_mysql_sg"
  description = "security group for serverless wordpress mysql"
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
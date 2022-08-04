output "remote_state_vpc_public_subnets" {
    value = data.terraform_remote_state.vpc.outputs.public_subnets
}

output "private_key" {
  value     = tls_private_key.generate_ssh.private_key_pem
  sensitive = true
}
output "wordpress_bitnami_ami" {
  value = data.aws_ami.wordpress_bitnami.id
}

output "mysql_admin_password" {
  value = random_password.mysql_password.result
  sensitive = true
}

resource "local_file" "private_key" {
  content         = tls_private_key.generate_ssh.private_key_pem
  filename        = "${var.base_path}/wordpress_ssh_terraform_key.pem"
  file_permission = "0600"
}
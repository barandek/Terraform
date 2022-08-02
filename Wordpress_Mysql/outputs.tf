output "remote_state_vpc_public_subnets" {
    value = data.terraform_remote_state.vpc.outputs.public_subnets
}

output "private_key" {
  value     = tls_private_key.generate_ssh.private_key_pem
  sensitive = true
}

resource "local_file" "private_key" {
  content         = tls_private_key.generate_ssh.private_key_pem
  filename        = "wordpress_ssh_key.pem"
  file_permission = "0600"
}
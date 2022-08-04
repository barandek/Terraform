#  # Installing required softwares into the system!
#  connection {
#    type = "ssh"
#    user = "ec2-user"
#    private_key = file("Key.pem")
#    host = aws_instance.webserver.public_ip
#  }
#
#  # Code for installing the softwares!
#  provisioner "remote-exec" {
#    inline = [
#        "sudo yum update -y",
#        "sudo yum install php php-mysqlnd httpd -y",
#        "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
#        "tar -xzf wordpress-4.8.14.tar.gz",
#        "sudo cp -r wordpress /var/www/html/",
#        "sudo chown -R apache.apache /var/www/html/",
#        "sudo systemctl start httpd",
#        "sudo systemctl enable httpd",
#        "sudo systemctl restart httpd"
#    ]
#  }
#}
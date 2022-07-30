resource "aws_instance" "ins1" {
    count = var.ha_az
    ami = data.aws_ami.ec2_most_recent_linux.id
    instance_type = var.instance_type_map["${local.environment}"]
    # Expose metadata of the instance and hello-world
    user_data = file("${path.module}/scripts/ec2-configure.sh")
    # Assign to created VPC
    #subnet_id = aws_subnet.public_subnet.id
    subnet_id = module.vpc.public_subnets[count.index]
    # Associate a public IP address
    associate_public_ip_address = true
    tags = merge(
        # This configuration combines some "default" tags with optionally provided additional tags
        local.common_tags,
        {
            Name = "t2-micro-test-${count.index}"
            #AZ = "${element(data.aws_availability_zones.az_available.names, count.index)}"
        },
    )
    # Make sure root volume gets deleted after you destroy EC2 instance
    # root device for an instance launched from the AMI is an Amazon EBS backed volume
    root_block_device {
        delete_on_termination = true 
        volume_size = 8
        volume_type = "gp2"
    }
    # Configure security group with SSH/HTTPs enabled
    vpc_security_group_ids = [aws_security_group.sg_ssh_https.id]
    # SSH key configuration
    key_name = var.instance_keypair
    # Create instances with meta-arguments (count)
    # Availability Zones - ensure High Availability
    # Filtered output
    availability_zone = "${element(local.az_filtered, count.index)}"
}

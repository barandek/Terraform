resource "aws_instance" "ins1" {
    count = var.use_asg_spot == true ? 0 : var.ec2_numInstances
    ami = var.bitnami_wordpress_ami_id != null ? var.bitnami_wordpress_ami_id : data.aws_ami.wordpress_bitnami.id
    instance_type = var.instance_type_map["${local.environment}"]
    #user_data = file("${path.module}/scripts/ec2-configure.sh")
    # Assign to created VPC
    # Availability Zones / Subnets
    subnet_id = var.ec2_public_subnet == true ? element(data.terraform_remote_state.vpc.outputs.public_subnets, count.index) : element(data.terraform_remote_state.vpc.outputs.private_subnets, count.index)
    # Associate a public IP address
    associate_public_ip_address = var.ec2_public_subnet == true ? true : false
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
        volume_size = var.ec2_EBSvolumeSize
        volume_type = "gp2"
    }
    # Configure security group with SSH/HTTPs enabled
    vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.sg_ssh_https]
    # SSH key configuration
    key_name = var.ec2_custom_ssh_keypair_name != null ? var.ec2_custom_ssh_keypair_name : aws_key_pair.generated_key_ssh.key_name
}

resource "aws_instance" "t2_micro" {
    ami = data.aws_ami.ec2_most_recent_linux.id
    instance_type = "t2.micro"
    tags = merge(
        # This configuration combines some "default" tags with optionally provided additional tags
        local.common_tags,
        {
            Name = "t2-micro-test"
        },
    )
    # Make sure root volume gets deleted after you destroy EC2 instance
    # root device for an instance launched from the AMI is an Amazon EBS backed volume
    root_block_device {
        delete_on_termination = true 
        volume_size = 8
        volume_type = "gp2"
    }
}
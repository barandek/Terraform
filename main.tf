resource "aws_instance" "t2_micro" {
    ami = data.aws_ami.ec2_most_recent_linux.id
    instance_type = "t2.micro"
    
}
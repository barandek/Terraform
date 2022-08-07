# terraform_courses
Learning Terraform

This repository created to practice/learn Terraform and present the code that I used 
My Terraform skills includes:

EC2:
- create ec2 instances (instane type, ami) with count index
- find latest ec2 ami image (filter by values)
- ssh key configuration / generate ssh key pair
- custom user data scripts
- High Availability EC2 instances (across 2 AZ)
- ASG with Spot instances and Capacity Rebalance
- ALB with attachments with Target Groups and HTTP/HTTPS redirections

BACKUPS:
- configure backend terraform state files on aws s3

RDS:
- create RDS/mysql cluster

NETWORKS:
- create vpc, subnets, route tables, main route table
- IGW
- security groups, custom sg rules
- VPC module implementation
- ssl certificates (ACM) for ALB https traffic
 
Terraform:
- configure required providers for aws 
- output the most important values (using for loops)
- declare and use variables (string, map, list types)
- tag resources with custom names
- aws - availability zones data source 
- use count/for loops
- filtering output with condition/ key function
- dynamic blocks (for ex. used in security groups)
- using terraform_remote_state data source
- split resources into folders (separate parts of architecture)
- conditions ? : (if/else)
- "slice" extracts some consecutive elements from within a list
- use "element" function to loop over list
- create local_file with SSH key

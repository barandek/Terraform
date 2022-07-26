# terraform_courses
Learning Terraform

This repository created to practice/learn Terraform and present the code that I used 
My Terraform skills includes:

EC2:
- create ec2 instances (instane type, ami) with count index
- find latest ec2 ami image (filter by values)
- ssh key configuration
- custom user data scripts
- High Availability EC2 instances (across 2 AZ)

BACKUPS:
- configure backend terraform state files on aws s3

NETWORKS:
- create vpc, subnets, route tables, main route table
- IGW
- security groups, custom sg rules
- VPC module implementation
- dynamic blocks (for ex. used in security groups)
 
Terraform:
- configure required providers for aws 
- output the most important values (using for loops)
- declare and use variables (string, map, list types)
- tag resources with custom names
- aws - availability zones data source 
- use count/for loops
- filtering output with condition/ key function

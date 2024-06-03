# create a service on the cloud - launch a ec2 instance on aws
# HCL syntax key = value

# which part of AWS - which region

provider "aws"{

        region = var.sparta_region
}
# aws-access-key-id = the key DO NOT HARDCODE
# aws-secret-access-key = the key DO NOT HARDCODE
# MUST NOT PUSH TO GITHUB UNTIL WE HAVE CREATED A .gitignore file together
# which service/resource/s - ec2
provider "github" {

  token = var.git_token

}
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_ip
  
  tags = {
    Name = "lewis_terraform_vpc"
  }
}
resource "aws_security_group" "app_security_group" {
  vpc_id      = aws_vpc.vpc.id 
  name        = "lewis-terraform-app-security-group"
  description = "Allow SSH, HTTP, and Node inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ip_access
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ip_access
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.ip_access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ip_access
  }
}
resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.app_subnet_ip
  availability_zone = var.az_one

  tags = {
    Name = "lewis_subnet_app"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.db_subnet_ip
  availability_zone = var.az_two

  tags = {
    Name = "lewis_subnet_db"
  }
}
resource "aws_instance" "app_instance" {

# which type of instance - ami to use
       ami = var.ami_id
       

# t2micro
       instance_type = var.instance_type_used

# app_subnet
       subnet_id = aws_subnet.app_subnet.id

# SG group
       vpc_security_group_ids = [aws_security_group.app_security_group.id]

# associate public ip with this instance
        associate_public_ip_address = true

# name  the ec2/resource
        tags = {
             Name = "lewis-terraform-tech258-app"
      }
}
resource "github_repository" "automated_repo" {
  name        = "IaC-github-automated-repo"
  description = "automated terraform repo"
  visibility  = "public"
}





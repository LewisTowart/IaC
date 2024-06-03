provider "aws"{

        region = var.sparta_region
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
resource "aws_security_group" "db_security_group" {
  vpc_id      = aws_vpc.vpc.id 
  name        = "lewis-terraform-db-security-group"
  description = "Allow SSH, Mongo"
  ingress {
    from_port   = 27017
    to_port     = 27107
    protocol    = "tcp"
    cidr_blocks = var.ip_access
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table" "app-route-table" {
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
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
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.app_subnet.id
    route_table_id = aws_route_table.app-route-table.id
}
resource "aws_instance" "db" {
    ami = "ami-03b1f76707acf93f8"
    instance_type = "t2.micro"
    availability_zone = "eu-west-1b"
    
    vpc_security_group_ids = [aws_security_group.db_security_group.id]

    subnet_id = aws_subnet.db_subnet.id

    associate_public_ip_address = true

    tags = {
        Name = "tech258-lewis-db"
    }
}
resource "aws_instance" "app" {
    ami = var.ami_id
    instance_type = "t2.micro"
    availability_zone = "eu-west-1a"
    
    vpc_security_group_ids = [aws_security_group.app_security_group.id]
    
    subnet_id = aws_subnet.app_subnet.id


    associate_public_ip_address = true

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
                sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y

                sudo sed -i '51s/.*/\t        proxy_pass http:\/\/localhost:3000;/' /etc/nginx/sites-enabled/default
                sudo systemctl restart nginx
                sudo systemctl enable nginx
                
                export DB_HOST=mongodb://${aws_instance.db.private_ip}:27017/posts

                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo DEBIAN_FRONTEND=noninteractive -E bash - &&\
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
            
                sudo git clone https://github.com/LewisTowart/tech258-sparta-test-app.git /repo

                cd /repo/app

                npm install

                sudo npm install -g pm2 
                pm2 stop all
                pm2 start app.js 
                EOF
    tags = {
        Name = "tech258-lewis-app"
    }
}
# store in s3 bucket
# terraform {
#   backend "s3" {
#     bucket = "tech258-lewis-terraform-bucket"
#     key = "dev/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }
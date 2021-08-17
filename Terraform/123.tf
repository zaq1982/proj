terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}

# 1 Create VPC
# 2 Create Internet Gateway
# 3 Create Custom Route Table
# 4 Create a Subnet
# 5 Associate a Subnet with Route Table
# 6 Create Security group to allow port 22,80,443
# 7 Create a network interface with an ip that was created in step 4
# 8 Assign elastic IP to the network interface created in step 7
# 9 Create EC2 instance



# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
#  access_key = "111111111"
#  secret_key = "1111111"
}

# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myVPC"
  }
}

resource "aws_internet_gateway" "myVPC-igw" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myVPC-igw"
  }
}


resource "aws_route_table" "myVPC-route-table" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myVPC-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
 #   egress_only_gateway_id = aws_internet_gateway.myVPC-igw.id
    gateway_id = aws_internet_gateway.myVPC-igw.id
  }


  tags = {
    Name = "myVPC-route-table"
  }
}



resource "aws_subnet" "myVPC-subnet1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "myVPC-subnet1"
  }
}

resource "aws_route_table_association" "subnet1-association" {
  subnet_id      = aws_subnet.myVPC-subnet1.id
  route_table_id = aws_route_table.myVPC-route-table.id
}


resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "allow_connections_and_web_traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description      = "22 port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  
  ingress {
    description      = "443 port"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "80 port"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "8080 port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_connections"
  }
}


resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.myVPC-subnet1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]

 # attachment {
 #   instance     = aws_instance.test.id
 #   device_index = 1
 # }
}

resource "aws_eip" "myVPC-eip-one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.myVPC-igw]
}

output "server_public_ip" {
  value       = aws_eip.myVPC-eip-one.public_ip
  
}



resource "aws_instance" "web-server-instance"{
    ami = "ami-0747bdcabd34c712a"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "key1"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo you web server > /var/www/html/index.html'
                EOF
    tags = {
      Name = "web-server"
    }
}

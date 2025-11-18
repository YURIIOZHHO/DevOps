resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.aws_public_subnet

  tags = {
    Name = "public subnet"
  }
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "security group"
  }   
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rule_for_ssh" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4 = var.aws_range_traffic
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22

   tags = {
    Name = "ingress rule for ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rule_for_tcp" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4 = var.aws_range_traffic
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80

  tags = {
    Name = "ingress rule for tcp"
  }
}


resource "aws_vpc_security_group_egress_rule" "sg_egress_rule" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4 = var.aws_range_traffic
  ip_protocol = "-1"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.aws_range_traffic
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "public route table"
  }
}

resource "aws_route_table_association" "assoc_route_and_subnet" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_instance" "ec2_instence" {
  subnet_id = aws_subnet.public_subnet.id
  ami = var.aws_ec2_ami

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF


  vpc_security_group_ids = [aws_security_group.security_group.id]  
  instance_type = var.aws_ec2_type
  key_name = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "EC2 Instance"
  }
}


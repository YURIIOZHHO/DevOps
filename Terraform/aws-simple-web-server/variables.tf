variable "aws_region" {
  description = "AWS region to launch server in."
  type = string
  default = "eu-central-1"
}

variable "aws_vpc" {
  description = "VPC for my instance"
  type = string
  default = "10.0.0.0/16"
}

variable "aws_public_subnet" {
  description = "public subnet range"
  type = string
  default = "10.0.1.0/24"
}

variable "aws_range_traffic" {
  description = "range of traffic"
  type = string
  default = "0.0.0.0/0"
}

variable "aws_ec2_ami" {
  description = "ec2 ami"
  type = string
  default = "ami-0a6793a25df710b06"
}

variable "aws_ec2_type" {
  description = "Type of ec2"
  type = string
  default = "t3.micro"
}

variable "key_name" {
  description = "key for remote access"
  type = string
  default = "web-server-key"
}





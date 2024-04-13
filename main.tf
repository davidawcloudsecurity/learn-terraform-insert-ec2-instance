provider "aws" {
  region = var.aws_region
}

resource "aws_subnet" "existing_subnet" {
  vpc_id     = var.your_existing_vpc_id
  cidr_block = var.your_existing_subnet_cidr
}

resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.your_existing_vpc_id

  // Define ingress and egress rules as needed
}

data "aws_ami" "custom_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["your_custom_ami_name"]
  }
}

resource "aws_instance" "example_server" {
  ami           = data.aws_ami.custom_ami.id
  instance_type = "t2.micro"
  subnet_id          = aws_subnet.existing_subnet.id

  tags = {
    Name = "JacksBlogExample"
  }
}
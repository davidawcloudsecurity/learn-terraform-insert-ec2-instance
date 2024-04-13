provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.your_existing_vpc_id

  // Define ingress and egress rules as needed
}

resource "aws_instance" "example_server" {
  ami           = local.ami
  instance_type = local.type
  subnet_id     = var.your_existing_subnet_id

  tags = {
    Name = "var.project_tag"
  }
}
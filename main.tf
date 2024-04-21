provider "aws" {
  region = var.aws_region
}

locals {
  type_linux   = "t2.micro"
  type_windows = "t2.micro"
  tags = {
    Project     = "IM8"
    Name        = "Created by infra"
    Environment = "Development" # Staging / Production / Development
  }
}

# Check if instance exists
data "aws_instances" "existing_instances" {
  filter {
    name   = "vpc-id"
    values = [var.instance_id]
  }
  filter {
    name   = "subnet-id"
    values = [var.instance_id]
  } 
}

data "aws_key_pair" "existing_key_pair" {
  key_name = var.existing_key_pair # Change "your_key_pair_name" to the name of the key pair you want to check
}

data "aws_security_group" "existing_security_group" {
  id = var.your_existing_security_group # Change the security group ID to the one you want to check
}

// create new security group
/*
resource "aws_security_group" "example_server_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.your_existing_vpc_id

  // Define ingress and egress rules as needed
  ingress {
    description     = "HTTPS ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.your_existing_security_group]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

# Create the IAM role ARN (e.g arn:aws:iam::76739xxxxx:role/aws_iam_role_syslog_server_role)
resource "aws_iam_role" "syslog_server_role" {
  name = "aws_iam_role_syslog_server_role"

  # Define the permissions for the IAM role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach-ssm" {
  role       = aws_iam_role.syslog_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the CloudWatchAgentAdminPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-admin" {
  role       = aws_iam_role.syslog_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

# Attach the CloudWatchAgentServerPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server" {
  role       = aws_iam_role.syslog_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create an instance profile ARN (e.g. arn:aws:iam::7673xxxxxx:instance-profile/aws_iam_instance_profile_syslog_server_profile)
resource "aws_iam_instance_profile" "syslog_server_profile" {
  name = "aws_iam_instance_profile_syslog_server_profile"
  role = aws_iam_role.syslog_server_role.name
}

# Remove to create new iam policy for ec2
/*
resource "aws_instance" "example_server_new_policy" {
  ami                         = var.ami_id_linx
  instance_type               = local.type
  subnet_id                   = var.your_existing_subnet_id
  user_data                   = var.string_heredoc_type
  vpc_security_group_ids      = [var.your_existing_security_group] # Use the ID of the existing security group
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_tag}-new-policy"
  }
}
*/
resource "aws_instance" "example_linux_existing_policy" {

  ami                    = var.ami_id_linux
  instance_type          = local.type_linux
  subnet_id              = var.your_existing_subnet_id
  key_name               = var.existing_key_pair
  user_data              = var.string_heredoclinux_type
  vpc_security_group_ids = [var.your_existing_security_group]
  #  vpc_security_group_ids      = [aws_security_group.example_server_sg.id] // create new sg
  iam_instance_profile        = var.your_existing_iam_instance_profile
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = true
  }

  tags = {
    Project     = local.tags.Project
    Name        = "syslog"
    Environment = local.tags.Environment
  }
}

resource "aws_instance" "example_windows_existing_policy" {
  ami                    = var.ami_id_windows
  instance_type          = local.type_windows
  subnet_id              = var.your_existing_subnet_id
  key_name               = var.existing_key_pair
  user_data              = var.string_heredocwindows_type
  vpc_security_group_ids = [var.your_existing_security_group]
  #  vpc_security_group_ids      = [aws_security_group.example_server_sg.id] // create new sg
  iam_instance_profile        = var.your_existing_iam_instance_profile
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = true
  }

  tags = {
    Project     = local.tags.Project
    Name        = "JH"
    Environment = local.tags.Environment
  }
}

output "instance_exists" {
  value = length(data.aws_instances.existing_instances.ids) > 0
}

output "key_pair_exists" {
  value = length(data.aws_key_pair.existing_key_pair.key_pairs) > 0
}

output "security_group_exists" {
  value = length(data.aws_security_group.existing_security_group.ids) > 0
}

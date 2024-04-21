provider "aws" {
  region = var.aws_region
}

locals {
  ami_linux    = "ami-0fe630eb857a6ec83"
  ami_windows  = "ami-0d2a904b23cbe737a"
  type_linux   = "t2.micro"
  type_windows = "t2.micro"
  key_pair_exists = can(data.aws_key_pair.existing[*].key_name)
  tags = {
    Project     = "IM8"
    Name        = "Created by infra"
    Environment = "Development" # Staging / Production / Development
  }
}

data "aws_key_pair" "existing" {
  count   = local.key_pair_exists ? 1 : 0
  key_name = var.existing_key_pair
}

data "aws_key_pair" "generated" {
  count   = local.key_pair_exists ? 0 : 1
  key_name = var.existing_key_pair
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

# Create the IAM role ARN
resource "aws_iam_role" "ssm_role" {
  name = "aws_iam_role_ssm_role"

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
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the CloudWatchAgentAdminPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-admin" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

# Attach the CloudWatchAgentServerPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create an instance profile ARN (e.g. arn:aws:iam::7673xxxxxx:instance-profile/aws_iam_instance_profile_ssm_profile)
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "aws_iam_instance_profile_ssm_profile"
  role = aws_iam_role.ssm_role.name
}

# Remove to create new iam policy for ec2
/*
resource "aws_instance" "example_server_new_policy" {
  ami                         = local.ami
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
  ami                    = local.ami_linux
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
  ami                    = local.ami_windows
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

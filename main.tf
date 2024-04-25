provider "aws" {
  region = var.aws_region
}

locals {
  type_linux   = "t2.micro"
  type_windows = "t2.micro"
  tags = {
    Project     = "IM8"
    Name        = "Created by infra"
    Environment = "Staging" # Staging / Production / Development
  }
}

# Check if vpc exists
data "aws_instances" "existing_vpc_subnet" {
  filter {
    name   = "vpc-id"
    values = [var.your_existing_vpc_id]
  }
  filter {
    name   = "subnet-id"
    values = [var.your_existing_subnet_id]
  }
}

data "aws_security_group" "existing_security_group" {
  id = var.your_existing_security_group # Change the security group ID to the one you want to check
}

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

resource "aws_instance" "example_nessus_existing_policy" {
  ami                    = var.ami_id_nessus
//  instance_type          = local.type_linux
  subnet_id              = var.your_existing_subnet_id
  key_name               = var.existing_key_pair
  vpc_security_group_ids = [var.your_existing_security_group]
  associate_public_ip_address = true
/*
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = true
  }
*/
  tags = {
    Project     = local.tags.Project
    Name        = "nessus_01"
    Environment = local.tags.Environment
  }
}

resource "aws_instance" "example_linux_existing_policy" {
  ami                    = var.ami_id_linux
  instance_type          = local.type_linux
  subnet_id              = var.your_existing_subnet_id
  key_name               = var.existing_key_pair
  user_data              = var.string_heredoclinux_type
  vpc_security_group_ids = [var.your_existing_security_group]
  #  vpc_security_group_ids      = [aws_security_group.example_server_sg.id] // create new sg
  iam_instance_profile        = aws_iam_instance_profile.syslog_server_profile.name
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  tags = {
    Project     = local.tags.Project
    Name        = "syslog_server_01"
    Environment = local.tags.Environment
  }
}

resource "aws_instance" "example_windows_existing_policy" {
  ami                    = var.ami_id_windows
  instance_type          = local.type_windows
  subnet_id              = var.your_existing_subnet_id
  key_name      = var.existing_key_pair != "" ? var.existing_key_pair : null
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
    Name        = "JH_01"
    Environment = local.tags.Environment
  }
}

output "vpc_subnet_exists" {
  value = length(data.aws_instances.existing_vpc_subnet.id) > 0 ? "Syslog-Server-ID: ${aws_instance.example_linux_existing_policy.id} JH-ID: ${aws_instance.example_windows_existing_policy.id}" : "VPC or subnet does not exist"
}

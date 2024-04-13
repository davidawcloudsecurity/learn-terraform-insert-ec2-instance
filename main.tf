provider "aws" {
  region = var.aws_region
}

// create new security group

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

# Get the policy by name
data "aws_iam_policy" "ssm-policy" {
  name = "AmazonSSMManagedInstanceCore"
}

# Create the IAM role
resource "aws_iam_role" "test_role" {
  name = "ssm-system-role3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-ssm" {
  role       = aws_iam_role.test_role.name
  policy_arn = data.aws_iam_policy.ssm-policy.arn
}

resource "aws_instance" "example_server_new_policy" {
  ami           = local.ami
  instance_type = local.type
  subnet_id     = var.your_existing_subnet_id
  user_data     = var.string_heredoc_type
  # Use the ID of the existing security group
  vpc_security_group_ids = [var.your_existing_security_group]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name

  tags = {
    Name = "${var.project_tag}-new-policy"
  }
}

resource "aws_instance" "example_server_existing_policy" {
  ami           = local.ami
  instance_type = local.type
  subnet_id     = var.your_existing_subnet_id
  user_data     = var.string_heredoc_type
  // create new sg
  vpc_security_group_ids = [aws_security_group.example_server_sg.id]
  iam_instance_profile   = "AmazonSSMManagedInstanceCore_Role"
  tags = {
    Name = var.project_tag
  }
}
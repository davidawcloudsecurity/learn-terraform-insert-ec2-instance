variable "aws_region" {
  description = "The az (e.g., us-east-1, us-east-2)"
  type        = string
  default     = "us-east-1"
}

variable "use_existing_infra" {
  description = "True to use existing id. False to provide one"
  type        = bool
  default     = true
}

variable "your_existing_vpc_id" {
  description = "The vpc id the instance will be created (e.g., vpc-086340xxxxxxxxxxx)"
  type        = string
  default     = "vpc-08af00a9da60f1f70"
}

variable "your_existing_subnet_id" {
  description = "Specifies the main CIDR block."
  type        = string
  default     = "subnet-009f1fe543c8a0daa"
}

variable "your_existing_security_group" {
  description = "Specifies the exisiting security group"
  type        = string
  default     = "sg-00fad24cc88e4e8d3"
}

variable "your_existing_iam_instance_profile" {
  description = "Specifies the exisiting security group"
  type        = string
  default     = "AmazonSSMManagedInstanceCore"
}

variable "project_tag" {
  description = "Specifies the name tag."
  type        = string
  default     = "learn-tf-insert-ec2"
}

variable "string_heredoclinux_type" {
  description = "This is a variable of type string"
  type        = string
  default     = <<EOF
#!/bin/bash

# Define the path to the sshd_config file
sshd_config="/etc/ssh/sshd_config"

# Define the string to be replaced
old_string="PasswordAuthentication no"
new_string="PasswordAuthentication yes"

# Check if the file exists
if [ -e "$sshd_config" ]; then
    # Use sed to replace the old string with the new string
    sudo sed -i "s/$old_string/$new_string/" "$sshd_config"

    # Check if the sed command was successful
    if [ $? -eq 0 ]; then
        echo "PasswordAuthentication set to 'yes' in $sshd_config."
        # Restart the SSH service to apply the changes
        sudo systemctl restart sshd
    else
        echo "Error replacing string in $sshd_config."
    fi
else
    echo "File $sshd_config not found."
fi

# Set password for ec2-user
echo "your_new_password" | sudo passwd --stdin ec2-user

# Restart SSH service again to apply password authentication changes
sudo systemctl restart sshd
EOF
}

variable "string_heredocwindows_type" {
  description = "This is a variable of type string"
  type        = string
  default     = <<EOF
<script>
net users user2 Letmein2021 /add /passwordchg:yes
net users admin2 Letmein2021 /add /passwordchg:yes
net localgroup Administrators admin2 /add
net localgroup "Remote Desktop Users" user2 /add
</script>
EOF
}
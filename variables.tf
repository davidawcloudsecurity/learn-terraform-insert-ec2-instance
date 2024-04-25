variable "aws_region" {
  description = "The az (e.g., us-east-1, us-east-2)"
  type        = string
  default     = "us-east-1"
}

variable "prerequisite" {
  description = "Ensure you have ami-id, vpc-id, subnet-id, security group id, iam role and key pair name in hand (Press enter to continue)"
  type        = string  
}

variable ami_id_linux {
  description = "Ensure you have ami-id for syslog"
  type        = string
  default     = "ami-0fe630eb857a6ec83"
}

variable ami_id_nessus {
  description = "Ensure you have ami-id for syslog"
  type        = string
  default     = "ami-0fe630eb857a6ec83"
}

variable ami_id_windows {
  description = "Ensure you have ami-id for JH"
  type        = string
  default     = "ami-0d2a904b23cbe737a"
}

variable "use_existing_infra" {
  description = "True to use existing id. False to provide one"
  type        = bool
  default     = true
}

variable "existing_key_pair_exists" {
  description = "Set to true if the existing key pair exists, otherwise set to false."
  type        = bool
  default     = true
}

variable "new_key_pair_name" {
  description = "Name of the new key pair to create"
  type        = string
  default     = "test-key-pair-exist"
}

variable "existing_key_pair" {
  description = "Name of the existing key pair"
  default     = ""
}

variable "your_existing_vpc_id" {
  description = "The vpc id the instance will be created (e.g., vpc-086340xxxxxxxxxxx)"
  type        = string
#  default     = "vpc-0b762f1aec5a58aa"  //test error
   default     = "vpc-0b762f1aec5a58aab"
}

variable "your_existing_subnet_id" {
  description = "Specifies the main CIDR block."
  type        = string
#  default     = "subnet-0dddb8c7287f799f" //test error
  default     = "subnet-0dddb8c7287f799fb"
}

variable "your_existing_security_group" {
  description = "Specifies the exisiting security group"
  type        = string
  default     = "sg-08eae2073477a7b03"
#  default     = "sg-08eae2073477a7b0" //test error
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
# Add user2
useradd user2
# Set the initial password for user2 (Letmein2021)
echo "Letmein2021" | passwd --stdin user2
# Force user2 to change their password upon next login
passwd --expire user2

# Add admin2
useradd admin2
# Set the initial password for admin2 (Letmein2021)
echo "Letmein2021" | passwd --stdin admin2

# Add admin2 to the Administrators group
usermod -aG wheel admin2

# Add user2 to the "Remote Desktop Users" group
usermod -aG wheel user2

# Get the operating system name
OS_NAME=$(uname -s)

# Check if the operating system is RHEL
if [ "$OS_NAME" == "Linux" ]; then
    if grep -q '^ID="rhel"' /etc/os-release; then
        # Get the machine architecture
        ARCH=$(uname -m)
        
        # Check if the architecture is ARM
        if [ "$ARCH" == "aarch64" ]; then
            # Actions for ARM architecture
            echo "RHEL on ARM Architecture"
            # Do something for ARM architecture
            dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
        elif [ "$ARCH" == "x86_64" ]; then
            # Actions for x64 architecture
            echo "RHEL on x64 Architecture"
            # Do something for x64 architecture
            dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
        else
            # Actions for other architectures
            echo "Unsupported Architecture"
            # Do something for other architectures
        fi
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    else
        # Actions for non-RHEL operating systems
        echo "Not RHEL"
        # Do something for non-RHEL operating systems
    fi
else
    # Actions for non-Linux operating systems
    echo "Not a Linux operating system"
    # Do something for non-Linux operating systems
fi
EOF
}

variable "string_heredocwindows_type" {
  description = "This is a variable of type string"
  type        = string
  default     = <<EOF
<powershell>
$password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
New-LocalUser -Name "user2" -Password $password -FullName "test user" -Description "test sign-in account" | Set-LocalUser -PasswordNeverExpires $false
Set-LocalUser -Name "user2" -PasswordNeverExpires $false
New-LocalUser -Name "admin2" -Password $password -FullName "test user" -Description "test sign-in account" | Set-LocalUser -PasswordNeverExpires $true
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "user2"
Add-LocalGroupMember -Group "Administrators" -Member "admin2"
</powershell>
EOF
}

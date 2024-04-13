variable "aws_region" {
  description = "The az (e.g., us-east-1, us-east-2)"
  type        = string
  default     = "us-east-1"
}

variable "your_existing_vpc_id" {
  description = "The vpc id the instance will be created (e.g., vpc-086340xxxxxxxxxxx)"
  type        = string
  default     = "vpc-086340a0c95fe4d4b"
}

variable "your_existing_subnet_cidr" {
  description = "Specifies the main CIDR block."
  type        = string
  default     = "10.0.0.0/26"
}

variable "project_tag" {
  description = "Specifies the name tag."
  type        = string
  default     = "learn-tf-insert-ec2"
}
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

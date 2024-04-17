locals {
  ami_linux   = "ami-0fe630eb857a6ec83"
  ami_windows = "ami-0d2a904b23cbe737a"
  type        = "t2.micro"
  tags = {
    Name = "My Virtual Machine"
    Env  = "Dev"
  }
  subnet = "subnet-76a8163a"
}

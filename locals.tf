locals {
  ami_linux   = "ami-09b1e8fc6368b8a3a"
  ami_windows = "ami-06c02c227f8655310"
  type        = "t2.micro"
  tags = {
    Name = "My Virtual Machine"
    Env  = "Dev"
  }
  subnet = "subnet-76a8163a"
}

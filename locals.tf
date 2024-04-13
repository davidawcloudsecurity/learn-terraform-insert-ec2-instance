locals {
  ami  = "ami-0a699202e5027c10d"
  type = "t2.medium"
  tags = {
    Name = "My Virtual Machine"
    Env  = "Dev"
  }
  subnet = "subnet-76a8163a"
}
data "aws_key_pair" "existing" {
  count   = local.key_pair_exists ? 1 : 0
  key_name = var.existing_key_pair
}

data "aws_key_pair" "generated" {
  count   = local.key_pair_exists ? 0 : 1
  key_name = var.existing_key_pair
}

data "aws_key_pair" "existing" {
  count   = local.key_pair_exists ? 1 : 0
  key_name = var.existing_key_pair
}

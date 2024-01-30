#
# Key Pair
# Allows you to attach a key pair to the EC2 instances when they are created.
# This can be useful when you need to access your instances via bastion host.
#
data "aws_key_pair" "key_pair" {
  key_name           = var.key_pair_name
  include_public_key = true
}
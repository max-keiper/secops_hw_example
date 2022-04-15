resource "aws_key_pair" "ue1-access-key" {
  key_name   = "ue1-access-key"
  public_key = var.public_key
}
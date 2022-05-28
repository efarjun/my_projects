resource "aws_subnet" "subnet" {
  cidr_block = var.subnet_cidr
  vpc_id = var.vpc_id
}

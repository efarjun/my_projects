resource "aws_iam_group" "iam_group" {
  name = var.name
  path = var.path
  
  tags = var.tags
}

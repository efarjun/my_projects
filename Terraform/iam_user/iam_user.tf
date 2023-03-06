resource "aws_iam_user" "lb" {
  name = var.name
  path = var.path

  tags = var.tag
}

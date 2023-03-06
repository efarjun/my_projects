resource "aws_iam_user" "iam_user" {
  name = var.name
  path = var.path

  tags = var.tag
}

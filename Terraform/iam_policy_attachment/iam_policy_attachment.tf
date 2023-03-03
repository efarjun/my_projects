resource "aws_iam_policy_attachment" "policy-attachment" {
  name       = var.name
  users      = var.users
  roles      = var.roles
  groups     = var.groups
  policy_arn = var.policy_arn
}

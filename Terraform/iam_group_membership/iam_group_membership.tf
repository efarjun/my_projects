resource "aws_iam_user_group_membership" "group_membership" {
  user = var.user

  groups = [
    var.group,
  ]
}

resource "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.repo_name
  description     = var.description
  default_branch = var.default_branch
}

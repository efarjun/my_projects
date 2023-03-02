resource "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.repo_name
  description     = var.description
  default_branch = var.default_branch
}

resource "aws_codecommit_trigger" "code_commit_trigger" {
  repository_name = aws_codecommit_repository.code_commit_repo.repository_name

  trigger {
    name            = var.trigger_name
    events          = var.trigger_events
    branches        = var.branches
    destination_arn = var.destination_arn
  }
}

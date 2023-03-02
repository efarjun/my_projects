output "repository_id" {
  value = aws_codecommit_repository.code_commit_repo.repository_id
}
output "repository_arn" {
  value = aws_codecommit_repository.code_commit_repo.arn
}
output "configuration_id" {
  value = aws_codecommit_trigger.code_commit_trigger.configuration_id
}

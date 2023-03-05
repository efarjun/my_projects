resource "aws_codecommit_trigger" "code_commit_trigger" {
  repository_name = aws_codecommit_repository.code_commit_repo.repository_name

  trigger {
    name            = var.trigger_name
    events          = var.trigger_events
    branches        = var.branches
    destination_arn = var.destination_arn
  }
}

output "configuration_id" {
  value = aws_codecommit_trigger.code_commit_trigger.configuration_id
}

variable "trigger_name" {
    description = "Name of trigger."
}
variable "events" {
    description = "The repository events that will cause trigger."
    type = list
    default = ["all"]
}
variable "branches" {
    description = "The branches that will be included in the trigger configuration."
    default = null
}
variable "destination_arn" {
    description = "The ARN of the resource that is the target for a trigger."
}

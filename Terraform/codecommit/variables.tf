variable "repo_name" {
    description = "Name of CodeCommit repository."
}
variable "description" {
    description = "Description of repository."
    default = null
}
variable "default_branch" {
    description = "Default branch of the repository."
    default = "main"
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

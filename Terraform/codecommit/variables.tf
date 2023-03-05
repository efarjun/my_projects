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

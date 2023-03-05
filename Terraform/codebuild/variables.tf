variable "project_name" {
    description = "Name of CodeBuild project."
}
variable "project_description" {
    description = "Project description."
}
variable "build_timeout" {
    default = null
}
variable "service_role" {
    description = "ARN of the IAM role for CoudeBuild."
}
variable "compute_type" {
    description = "Compute resource type."
    default = "BUILD_GENERAL1_SMALL"
}
variable "image" {
    description = "Docker image used for build."
    default = "aws/codebuild/standard:6.0"
}
variable "env_type" {
    description = "Build environment type."
    default = "LINUX_CONTAINER"
}
variable "image_pull_credentials_type" {
    description = "Type of credentials AWS CodeBuild uses to pull images in build."
    default = "CODEBUILD"
}
variable "source_type" {
    description = "Repository type that contains source code."
    default = "CODECOMMIT"
}
variable "source_location" {
    description = "Location of source code."
    default = null
}
variable "fetch_submodules" {
    type = bool
    default = true
}
variable "source_version" {
    default = null
}

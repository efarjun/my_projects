variable "codepipeline_iam_role" {
    description = "Name of IAM role to be used for CodePipeline."
}
variable "codepipeline_bucket_name" {
    description = "Name of S3 bucket for CodePipeline."
}
variable "codepipeline_name" {
    description = "Name of CodePipeline."
}
variable "artifact_store_type" {
    default = "S3"
}
variable "encryption_key_type" {
    default = "KMS"
}
variable "source_name" {
    description = "Name of source stage."
    default = "Source"
}
variable "source_category" {
    default = null
}
variable "source_owner" {
    default = "AWS"
}
variable "source_provider" {
    default = "CodeCommit"
}
variable "source_version" {
    default = 1
}
variable "source_output_artifacts" {
    type = list
    default = ["SourceArtifact"]
}
variable "source_variable_namespace" {
    default = "SourceVariables"
}
variable "repository_name" { 
    description = "name of the source repository."
}
variable "branch_name" {
    default = "main"
}
variable "output_artifact_format" {
    default = "CODE_ZIP"
}
variable "poll_for_source_changes" {
    type = bool
    default = false
}
variable "build_name" {
    description = "name of build stage."
    default = "Build"
}
variable "build_category" {
    default = null
}
variable "build_owner" {
    default = "AWS"
}
variable "build_provider" {
    default = "CodeBuild"
}
variable "build_input_artifacts" {
    type = list
    default = ["SourceArtifact"]
}
variable "build_output_artifacts" {
    type = list
    default = ["BuildArtifact"]
}
variable "build_version" {
    default = 1
}
variable "build_variable_namespace" {
    default = "BuildVariables"
}
variable "project_name" {
    description = "Name of build project."
}
variable "deploy_name" {
    default = "Deploy"
}
variable "deploy_category" {
    default = null
}
variable "deploy_owner" {
    default = "AWS"
}
variable "deploy_provider" {
    default = "S3"
}
variable "deploy_input_artifacts" {
    type = list
    default = ["BuildArtifact"]
}
variable "deploy_version" {
    default = 1
}
variable "deploy_variable_namespace" {
    default = "DeployVariables"
}
variable "extract" {
    type = bool
    default = true
}
variable "bucket_name" {
    description = "Name of S3 bucket for deployment."
}

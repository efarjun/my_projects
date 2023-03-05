locals {
    cw_log_group = "${var.project_name}-CodeBuild-log-group"
    cw_stream_name = "${var.project_name}-CodeBuild-log-stream"
}
resource "aws_codebuild_project" "codebuild_project" {
  name          = var.project_name
  description   = var.project_description
  build_timeout = var.build_timeout
  service_role  = var.service_role

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.env_type
    image_pull_credentials_type = var.image_pull_credentials_type

  logs_config {
    cloudwatch_logs {
      group_name  = local.cw_log_group
      stream_name = local.cw_stream_name
    }
  }
  source {
    type            = var.source_type

    git_submodules_config {
      fetch_submodules = var.fetch_submodules
      }
    }
  }
  source_version = var.source_version
}

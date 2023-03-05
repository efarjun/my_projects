data "aws_iam_role" "codepipeline_role" {
    name = var.codepipeline_iam_role
}

data "aws_s3_bucket" "codepipeline_bucket" {
    bucket = var.codepipeline_bucket_name
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = data.aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.codepipeline_bucket.bucket
    type     = var.artifact_store_type
  }
      
  stage {
    name = "Source"

    action {
      name             = var.source_name
      category         = var.source_category
      owner            = var.source_owner
      provider         = var.source_provider
      version          = var.source_version
      output_artifacts = var.source_output_artifacts
      namespace        = var.source_variable_namespace

      configuration = {
        RepositoryName       = var.repository_name
        BranchName           = var.branch_name
        OutputArtifactFormat = var.output_artifact_format
        PollForSourceChanges = var.poll_for_source_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = var.build_name
      category         = var.build_category
      owner            = var.build_owner
      provider         = var.build_provider
      input_artifacts  = var.build_input_artifacts
      output_artifacts = var.build_output_artifacts
      version          = var.build_version
      namespace        = var.build_variable_namespace

      configuration = {
        ProjectName = var.project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = var.deploy_name
      category        = var.deploy_category
      owner           = var.deploy_owner
      provider        = var.deploy_provider
      input_artifacts = var.deploy_input_artifacts
      version         = var.deploy_version
      namespace        = var.deploy_variable_namespace

      configuration = {
        Extract        = var.extract
        BucketName     = var.bucket_name
      }
    }
  }
}

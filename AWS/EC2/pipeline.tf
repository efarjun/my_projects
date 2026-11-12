moved {
  from = module.pipeline_common_east
  to   = module.pipeline_common_east[0]
}

module "pipeline_common_east" {
  count = terraform.workspace == "uat" ? 1 : 0

  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//pipeline?ref=main"

  providers = { aws = aws.common }

  project                = "abc"
  env                    = "common-east"
  module_name            = "ec2"
  working_dir            = "compute/ec2"
  artifact_bucket_name   = "abc-pipeline-artifacts"
  repo_name              = "abc-infra-live"
  codepipeline_role_name = "abc-codepipeline-role"
}

moved {
  from = module.pipeline_common_west
  to   = module.pipeline_common_west[0]
}

module "pipeline_common_west" {
  count = terraform.workspace == "uat" ? 1 : 0

  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//pipeline?ref=main"

  providers = { aws = aws.common }

  project                = "abc"
  env                    = "common-west"
  module_name            = "ec2"
  working_dir            = "compute/ec2"
  artifact_bucket_name   = "abc-pipeline-artifacts"
  repo_name              = "abc-infra-live"
  codepipeline_role_name = "abc-codepipeline-role"
}

moved {
  from = module.pipeline_uat
  to   = module.pipeline_uat[0]
}

module "pipeline_uat" {
  count = terraform.workspace == "uat" ? 1 : 0

  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//pipeline?ref=main"

  providers = { aws = aws.common }

  project                = "abc"
  env                    = "uat"
  module_name            = "ec2"
  working_dir            = "compute/ec2"
  artifact_bucket_name   = "abc-pipeline-artifacts"
  repo_name              = "abc-infra-live"
  codepipeline_role_name = "abc-codepipeline-role"
}

moved {
  from = module.pipeline_prod
  to   = module.pipeline_prod[0]
}

module "pipeline_prod" {
  count = terraform.workspace == "uat" ? 1 : 0

  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//pipeline?ref=main"

  providers = { aws = aws.common }

  project                = "abc"
  env                    = "prod"
  module_name            = "ec2"
  working_dir            = "compute/ec2"
  artifact_bucket_name   = "abc-pipeline-artifacts"
  repo_name              = "abc-infra-live"
  codepipeline_role_name = "abc-codepipeline-role"
}

moved {
  from = module.pipeline_dr
  to   = module.pipeline_dr[0]
}

module "pipeline_dr" {
  count = terraform.workspace == "uat" ? 1 : 0

  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//pipeline?ref=main"

  providers = { aws = aws.common }

  project                = "abc"
  env                    = "dr"
  module_name            = "ec2"
  working_dir            = "compute/ec2"
  artifact_bucket_name   = "abc-pipeline-artifacts"
  repo_name              = "abc-infra-live"
  codepipeline_role_name = "abc-codepipeline-role"
}

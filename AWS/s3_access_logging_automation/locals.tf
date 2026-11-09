locals {
  workspace = terraform.workspace

  allowed_workspaces = ["common-east", "common-west", "uat", "prod", "dr"]

  config = {
    common-east = {
      account_id        = "608420806074"
      environment       = "common"
      deployment_role   = "primary"
      region            = "us-east-2"
      log_target_bucket = "bhb-common-access-logs"
    }
    common-west = {
      account_id      = "608420806074"
      environment     = "common"
      deployment_role = "dr"
      region          = "us-west-2"
    }
    uat = {
      account_id      = "188612031843"
      environment     = "uat"
      deployment_role = "primary"
      region          = "us-east-2"
      log_target_bucket : "bhb-uat-access-logs"
    }
    prod = {
      account_id      = "119317299655"
      environment     = "prod"
      deployment_role = "primary"
      region          = "us-east-2"
      log_target_bucket : "bhb-prod-access-logs"
    }
    dr = {
      account_id      = "119317299655"
      environment     = "prod"
      deployment_role = "dr"
      region          = "us-west-2"
    }
  }

  current = local.config[local.workspace]

  assume_role_arn = "arn:aws:iam::${local.current.account_id}:role/iac"

common_tags = {
    Environment = local.current.environment
    Workspace   = local.workspace
    Region      = local.current.region
    Role        = local.current.deployment_role
    ManagedBy   = "terraform"
    Resource    = "lambda"
  }
}
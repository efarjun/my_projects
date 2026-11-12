locals {
  workspace = terraform.workspace

  allowed_workspaces = ["common-east", "common-west", "uat", "prod", "dr"]

  config = {
    common-east = {
      account_id      = "608424306094"
      environment     = "common"
      deployment_role = "primary"
      region          = "us-east-2"
      vpc_cidr        = "10.100.0.0/16"
    }
    common-west = {
      account_id      = "60849876074"
      environment     = "common"
      deployment_role = "dr"
      region          = "us-west-2"
      vpc_cidr        = "10.110.0.0/16"
    }
    uat = {
      account_id      = "188772031093"
      environment     = "uat"
      deployment_role = "primary"
      region          = "us-east-2"
      vpc_cidr        = "10.102.0.0/16"
    }
    prod = {
      account_id      = "119217098655"
      environment     = "prod"
      deployment_role = "primary"
      region          = "us-east-2"
      vpc_cidr        = "10.101.0.0/16"
    }
    dr = {
      account_id      = "177317294895"
      environment     = "prod"
      deployment_role = "dr"
      region          = "us-west-2"
      vpc_cidr        = "10.111.0.0/16"
    }
  }

  current = local.config[local.workspace]

  assume_role_arn = "arn:aws:iam::${local.current.account_id}:role/iac"

  # Map workspace to the correct directory ID from the AD module.
  # common-east/west use the primary directory (same account as AD owner).
  # Spoke accounts use their respective shared directory IDs.
  directory_id = (
    local.workspace == "common-east" || local.workspace == "common-west"
    ? data.terraform_remote_state.ad.outputs.directory_id
    : local.workspace == "uat"
    ? data.terraform_remote_state.ad.outputs.shared_directory_id_uat
    : data.terraform_remote_state.ad.outputs.shared_directory_id_prod_dr
  )

  # Common VPC CIDR for the same region — east workspaces use common-east, west use common-west.
  common_vpc_cidr = (
    local.current.region == "us-west-2" ? "10.110.0.0/16" : "10.100.0.0/16"
  )

  # common-west and dr point to the west replica DCs; all others use east.
  directory_dns_ip_addresses = (
    local.workspace == "common-west" || local.workspace == "dr"
    ? tolist(data.terraform_remote_state.ad.outputs.directory_dns_ip_addresses_west)
    : tolist(data.terraform_remote_state.ad.outputs.directory_dns_ip_addresses)
  )

  common_tags = {
    Environment = local.current.environment
    Workspace   = local.workspace
    Region      = local.current.region
    Role        = local.current.deployment_role
    ManagedBy   = "terraform"
    Resource    = "ec2"
  }

  # S3 bucket (central, in common account) where third-party installers are pre-staged.
  # Managed by compute/software-distribution. Spoke accounts access it cross-account.
  software_bucket = "abc-software-packages"

  # SSM Parameter Store paths — parameters are created by compute/software-distribution.
  ssm_umbrella_org_id      = "/abc/cisco-umbrella/org-id"
  ssm_umbrella_fingerprint = "/abc/cisco-umbrella/fingerprint"
  ssm_okta_url             = "/abc/okta/url"
  ssm_okta_client_id       = "/abc/okta/client-id"
  ssm_okta_client_secret   = "/abc/okta/client-secret"
  ssm_automox_access_key   = "/abc/automox/access-key"
  ssm_crowdstrike_cid      = "/abc/crowdstrike/cid"
}

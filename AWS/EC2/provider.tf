provider "aws" {
  region = local.current.region

  assume_role {
    role_arn     = local.assume_role_arn
    session_name = "terraform-${local.workspace}"
  }

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "common"
  region = "us-east-2"

  assume_role {
    role_arn     = "arn:aws:iam::608420806074:role/iac"
    session_name = "terraform-${local.workspace}-pipeline"
  }
}

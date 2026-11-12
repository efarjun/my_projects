terraform {
  backend "s3" {
    bucket               = "abc-terraform-bucket"
    key                  = "compute/ec2/terraform.tfstate"
    region               = "us-east-2"
    workspace_key_prefix = "env"
    dynamodb_table       = "terraform-state-lock"
    encrypt              = true
  }
}

resource "terraform_data" "workspace_guard" {
  input = terraform.workspace

  lifecycle {
    precondition {
      condition     = contains(local.allowed_workspaces, terraform.workspace)
      error_message = "Invalid workspace '${terraform.workspace}'. Use one of: ${join(", ", local.allowed_workspaces)}."
    }
  }
}

# Pull VPC outputs from remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket               = "abc-terraform-bucket"
    key                  = "network/vpc/terraform.tfstate"
    region               = "us-east-2"
    workspace_key_prefix = "env"
  }

  workspace = terraform.workspace
}

# ── IAM Instance Profile (managed in compute/iam) ────────────────────────────

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket               = "abc-terraform-bucket"
    key                  = "compute/iam/terraform.tfstate"
    region               = "us-east-2"
    workspace_key_prefix = "env"
  }

  workspace = terraform.workspace
}

# ── Security Groups ───────────────────────────────────────────────────────────

module "web_server_sg" {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//security-group?ref=main"

  name   = "abc-${local.workspace}-web-server-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules = [
    {
      description = "HTTP from Automox"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["18.236.0.200/32"]
    },
    {
      description = "HTTPS from Automox"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["18.236.0.200/32"]
    },
    {
      description = "RDP from management and common VPC"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = concat(var.management_cidr_blocks, [local.common_vpc_cidr])
    },
  ]
}

module "batch_server_sg" {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//security-group?ref=main"

  name   = "abc-${local.workspace}-batch-server-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["18.236.0.200/32"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["18.236.0.200/32"]
    },
    {
      description = "RDP from management and common VPC"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = concat(var.management_cidr_blocks, [local.common_vpc_cidr])
    },
  ]
}

# ── EC2 Instances ─────────────────────────────────────────────────────────────

module "web_server" {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//ec2?ref=main"

  name                          = "abc-${local.workspace}-web-server"
  instance_type                 = "t3.xlarge"
  subnet_id                     = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  vpc_id                        = data.terraform_remote_state.vpc.outputs.vpc_id
  key_name                      = "abc-${local.workspace}-key"
  iam_instance_profile          = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
  create_security_group         = false
  additional_security_group_ids = [module.web_server_sg.id]

  depends_on = [terraform_data.workspace_guard]
}

module "batch_server" {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/abc-terraform-modules//ec2?ref=main"

  name                          = "abc-${local.workspace}-batch-server"
  instance_type                 = "c5.large"
  subnet_id                     = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  vpc_id                        = data.terraform_remote_state.vpc.outputs.vpc_id
  key_name                      = "abc-${local.workspace}-key"
  iam_instance_profile          = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
  create_security_group         = false
  additional_security_group_ids = [module.batch_server_sg.id]

  depends_on = [terraform_data.workspace_guard]
}

# ── Active Directory Domain Join ──────────────────────────────────────────────

data "terraform_remote_state" "ad" {
  backend = "s3"

  config = {
    bucket = "abc-terraform-bucket"
    key    = "compute/active-directory/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_ssm_association" "domain_join" {
  for_each = {
    web_server   = module.web_server.instance_id
    batch_server = module.batch_server.instance_id
  }

  name = "AWS-JoinDirectoryServiceDomain"

  targets {
    key    = "InstanceIds"
    values = [each.value]
  }

  parameters = {
    directoryId    = local.directory_id
    directoryName  = "corp.birdsonghearing.com"
    dnsIpAddresses = tolist(local.directory_dns_ip_addresses)[0]
  }

  depends_on = [module.web_server, module.batch_server]
}

# ── AWS-managed packages (AWSCLI, CloudWatch Agent) ───────────────────────────

resource "aws_ssm_association" "aws_packages" {
  for_each = {
    cwagent = "AmazonCloudWatchAgent"
  }

  name             = "AWS-ConfigureAWSPackage"
  association_name = "abc-${local.workspace}-install-${each.key}"

  targets {
    key    = "InstanceIds"
    values = [module.web_server.instance_id, module.batch_server.instance_id]
  }

  parameters = {
    action = "Install"
    name   = each.value
  }

  depends_on = [module.web_server, module.batch_server]
}

# ── VSS agent for Windows EC2 backups ───────────────────────────

resource "aws_ssm_association" "vss_agent" {
  name = "AWSEC2-VssInstallAndSnapshot"

  targets {
    key    = "tag:AWS:InstanceInformation:PlatformName"
    values = ["Windows*"] 
  }

  parameters = {
    action    = "CreateSnapshot"
    imageTags = "AppConsistent=True,GlobalBackup=True"
  }
}

# ── Third-party packages (Cisco Umbrella, Okta Agent, Automox) ────────────────
# Installers are pre-staged in S3. Org keys are pulled from SSM Parameter Store.

resource "aws_ssm_association" "third_party_packages" {
  name             = "AWS-RunPowerShellScript"
  association_name = "abc-${local.workspace}-install-third-party"

  targets {
    key    = "InstanceIds"
    values = [module.web_server.instance_id, module.batch_server.instance_id]
  }

  parameters = {
    commands = join("\n", [
      # ── Cisco Umbrella ──────────────────────────────────────────────────────
      "$OrgId = (Get-SSMParameterValue -Name '${local.ssm_umbrella_org_id}' -WithDecryption $true).Parameters[0].Value",
      "$Fingerprint = (Get-SSMParameterValue -Name '${local.ssm_umbrella_fingerprint}' -WithDecryption $true).Parameters[0].Value",
      "Read-S3Object -BucketName ${local.software_bucket} -Key 'cisco-umbrella/umbrella-roaming-client.msi' -File $env:TEMP\\umbrella.msi",
      "Start-Process msiexec -ArgumentList \"/i $env:TEMP\\umbrella.msi /quiet ORG_ID=$OrgId FINGERPRINT=$Fingerprint\" -Wait",
      "Remove-Item $env:TEMP\\umbrella.msi -Force",

      # ── Okta Windows Credential Provider ────────────────────────────────────
      "$OktaUrl = (Get-SSMParameterValue -Name '${local.ssm_okta_url}').Parameters[0].Value",
      "$OktaClientId = (Get-SSMParameterValue -Name '${local.ssm_okta_client_id}' -WithDecryption $true).Parameters[0].Value",
      "$OktaClientSecret = (Get-SSMParameterValue -Name '${local.ssm_okta_client_secret}' -WithDecryption $true).Parameters[0].Value",
      "Read-S3Object -BucketName ${local.software_bucket} -Key 'okta/OktaWindowsCredentialProvider.msi' -File $env:TEMP\\OktaWindowsCredentialProvider.msi",
      "Start-Process msiexec -ArgumentList \"/i $env:TEMP\\OktaWindowsCredentialProvider.msi /quiet OKTA_URL=$OktaUrl CLIENT_ID=$OktaClientId CLIENT_SECRET=$OktaClientSecret\" -Wait",
      "Remove-Item $env:TEMP\\OktaWindowsCredentialProvider.msi -Force",

      # ── Automox ────────────────────────────────────────────────────────────
      "$AutomoxKey = (Get-SSMParameterValue -Name '${local.ssm_automox_access_key}' -WithDecryption $true).Parameters[0].Value",
      "Read-S3Object -BucketName ${local.software_bucket} -Key 'automox/automox-installer.msi' -File $env:TEMP\\automox.msi",
      "Start-Process msiexec -ArgumentList \"/i $env:TEMP\\automox.msi /quiet ACCESSKEY=$AutomoxKey\" -Wait",
      "Remove-Item $env:TEMP\\automox.msi -Force",

      # ── CrowdStrike Falcon ─────────────────────────────────────────────────
      "$CsCid = (Get-SSMParameterValue -Name '${local.ssm_crowdstrike_cid}' -WithDecryption $true).Parameters[0].Value",
      "Read-S3Object -BucketName ${local.software_bucket} -Key 'crowdstrike/WindowsSensor.exe' -File $env:TEMP\\WindowsSensor.exe",
      "Start-Process $env:TEMP\\WindowsSensor.exe -ArgumentList \"/install /quiet /norestart CID=$CsCid\" -Wait",
      "Remove-Item $env:TEMP\\WindowsSensor.exe -Force",

      # ── CloudWatch Agent ─────────────────────────────────────────────────
      "& 'C:\\Program Files\\Amazon\\AmazonCloudWatchAgent\\amazon-cloudwatch-agent-ctl.ps1' -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-${local.workspace}-Windows-Config"

      # ── CVE-2022-0001 ─────────────────────────────────────────────────
      "reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' /v FeatureSettingsOverride /t REG_DWORD /d 0x800048 /f"
      "reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' /v FeatureSettingsOverrideMask /t REG_DWORD /d 0x00000003 /f"

      # ── CVE-2016-2183 ─────────────────────────────────────────────────
      if (-not(test-path c:\share)) {
          mkdir c:\share
      }
      reg export "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers" "C:\share\registry_backup.reg" /y
      $path1 = "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
      $path2 = "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
      $command1 = "reg add `"$path1`" /v Enabled /t REG_DWORD /d 0 /f"
      $command2 = "reg add `"$path2`" /v Enabled /t REG_DWORD /d 0 /f"
      invoke-expression $command1
      invoke-expression $command2
    ])
  }

  depends_on = [module.web_server, module.batch_server]
}

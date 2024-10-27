# Set Execution Policy for the Process Scope
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -Scope Process -Force -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden -Wait

# Set TLS Protocol to TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = 'TLS12'

# Define variables
$code = "" # <-- Add Hybrid Activation Code
$id = "" <-- Add Hybrid Activation ID
$region = "us-east-1"
$dir = $env:TEMP + "\ssm"

# Create directory if it doesn't exist
if (-not (Test-Path -Path $dir -PathType Container)) {
    New-Item -ItemType directory -Path $dir -Force
}

# Download SSM Setup CLI
$setupCliUrl = "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/windows_amd64/ssm-setup-cli.exe"
$setupCliPath = Join-Path -Path $dir -ChildPath "ssm-setup-cli.exe"
Invoke-WebRequest -Uri $setupCliUrl -OutFile $setupCliPath

# Register SSM Setup CLI
Start-Process -FilePath $setupCliPath -ArgumentList "-register -activation-code=`"$code`" -activation-id=`"$id`" -region=`"$region`"" -Wait

# Get registration content
Get-Content ($env:ProgramData + "\Amazon\SSM\InstanceData\registration")

# Start Amazon SSM Agent service
Start-Service -Name "AmazonSSMAgent"

# Set Execution Policy for the Process Scope
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -Scope Process -Force -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden -Wait

# Set TLS Protocol to TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = 'TLS12'

# Define file paths
$msiFilePath = "C:\TeamViewer_Host.msi"
$fileSharePath = "TeamViewer_Host.msi"
$s3BucketPath = "s3://<S3 Bucket>/teamviewer/TeamViewer_Host.msi"
$teamViewerExePath = "C:\Program Files\TeamViewer\TeamViewer.exe"

# Function to check if a file exists
function Test-FileExistence {
    param (
        [string]$path
    )
    if (Test-Path $path) {
        return $true
    } else {
        return $false
    }
}

# Step 0: Check if TeamViewer is already installed in either path
if (Test-FileExistence -path $teamViewerExePath) {
    Write-Output "TeamViewer is already installed. Skipping installation."
    Exit 0
}

# Step 1: Try to copy the MSI from the file share
try {
    Write-Output "Attempting to copy MSI from file share..."
    Copy-Item -Path $fileSharePath -Destination $msiFilePath -Force
    if (Test-FileExistence -path $msiFilePath) {
        Write-Output "Successfully copied MSI from file share."
    } else {
        throw "File copy from file share failed."
    }
} catch {
    # Step 2: If file share copy fails, attempt to download from S3
    Write-Output "File share copy failed. Attempting to download MSI from S3..."
    try {
        aws s3 cp $s3BucketPath $msiFilePath --quiet
        if (Test-FileExistence -path $msiFilePath) {
            Write-Output "Successfully downloaded MSI from S3."
        } else {
            throw "File download from S3 failed."
        }
    } catch {
        Write-Output "Both file share and S3 download failed. Exiting script."
        Exit 1
    }
}

# Step 3: Install TeamViewer Host
Write-Output "Installing TeamViewer Host..."
Start-Process -FilePath "msiexec.exe" -ArgumentList '/i "C:\TeamViewer_Host.msi" /qn CUSTOMCONFIGID=<config id>' -Wait

# Wait for 30 seconds to ensure the installation completes
Start-Sleep -Seconds 30

# Step 4: Assign the TeamViewer host with the provided ID
Write-Output "Assigning TeamViewer Host..."
& "C:\Program Files\TeamViewer\TeamViewer.exe" assignment --id "<assignment id>"

# Step 5: Confirm installation was successful by checking the TeamViewer service
$service = Get-Service -Name "TeamViewer" -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq 'Running') {
    Write-Output "TeamViewer Host installed and running successfully."
} else {
    Write-Output "TeamViewer Host installation failed or the service is not running."
}

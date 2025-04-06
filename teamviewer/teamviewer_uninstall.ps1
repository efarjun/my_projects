# PowerShell script to uninstall TeamViewer from a Windows Server

# Define the registry paths where installed programs are listed
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Function to get the uninstall string for TeamViewer
function Get-TeamViewerUninstallString {
    foreach ($key in $uninstallKeys) {
        $apps = Get-ChildItem -Path $key -ErrorAction SilentlyContinue
        foreach ($app in $apps) {
            $displayName = (Get-ItemProperty -Path $app.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "TeamViewer*") {
                $uninstallString = (Get-ItemProperty -Path $app.PSPath -ErrorAction SilentlyContinue).UninstallString
                if ($uninstallString) {
                    return $uninstallString
                }
            }
        }
    }
    return $null
}

# Get the uninstall string for TeamViewer
$uninstallString = Get-TeamViewerUninstallString

if ($uninstallString) {
    Write-Output "TeamViewer found. Uninstalling..."

    # If the uninstall string contains 'msiexec', execute it differently
    if ($uninstallString -match "msiexec") {
        $uninstallCommand = $uninstallString -replace "msiexec.exe", "" -replace "/I", "/X"
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$uninstallCommand /quiet /norestart" -NoNewWindow -Wait
    } else {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString /S" -NoNewWindow -Wait
    }

    Write-Output "TeamViewer has been uninstalled."
} else {
    Write-Output "TeamViewer is not installed on this server."
}

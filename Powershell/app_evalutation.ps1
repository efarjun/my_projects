<#
.SYNOPSIS
    Uninstall all apps by name - Evaluation Script
    OS Support: Windows 7 and above
    Powershell: 2.0 and above
    Run Type: Evaluation Schedule or OnDemand
.DESCRIPTION
    This worklet is designed to allow an Admin to remove all instances of an application that matches a specific name.
    This is especially useful when trying to remove applications that allow multiple versions to be installed at the
    same time on a single device. This will include user based installations, which are handled by generating, and removing
    a scheduled task.

    Usage: There is only one variable that is used in this evaluation script. This defines the application name to be targeted.

    $appName: This is where you define the application name to be targeted. You can use a partial name, although be sure
    that it is unique enough to prevent accidental uninstalls of similarly named apps. Spaces are allowed, however do not
    use wildcards as they are already accounted for in the main body of the script.
.EXAMPLE
    $appName = 'winrar'
.NOTES
    Author: eliles
    Date: June 7, 2023
#>
### Edit within this block ####
$appName = 'Java 8 Update 451 (64-bit)'
###############################

# Check 64bit hive on x64 devices
if([System.Environment]::Is64BitOperatingSystem)
{
    $hklm64 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,[Microsoft.Win32.RegistryView]::Registry64)
    $skey64 = $hklm64.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Uninstall")
    $unkeys64 = $skey64.GetSubKeyNames()
    foreach($key in $unkeys64)
    {
        if($skey64.OpenSubKey($key).getvalue('DisplayName') -like "*$AppName*" -and !($skey64.OpenSubKey($key).getvalue("SystemComponent")))
        {
            $remediate += 1
        }
    }
}

# Check 32bit hive on 32/64 bit devices
$skey32 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($key in Get-ChildItem $skey32 -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -like "*$AppName*" -and !($_.SystemComponent))})
{
    $remediate += 1
}

# Scan HKU for installed instance of $appname
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
foreach($usr in Get-ChildItem -Path "HKU:\")
{
    foreach($guid in Get-ChildItem "HKU:\$usr\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -like "*$AppName*" -and !($_.SystemComponent))})
    {
        $remediate += 1
    }
}
Remove-PSDrive HKU

# Check for remediation
if($remediate)
{
    Write-Output "$remediate Installations found - Flagging for Remediation"
    Exit 1
}
Write-Output "Installed software was not found - Remediation not needed"
Exit 0

<#
.SYNOPSIS
    Uninstall all apps by name - Remediation Script
    OS Support: Windows 7 and above
    Powershell: 2.0 and above
    Run Type: Evaluation Schedule or OnDemand
.DESCRIPTION
    This worklet is designed to allow an Admin to remove all instances of an application that matches a specific name.
    This is especially useful when trying to remove applications that allow multiple versions to be installed at the
    same time on a single device.

    While applications that are installed via Windows Installer (MSI) use a standard set of commands, software that
    installs using an EXE often requires specific commands to uninstall the application silently without user intervention.

    It is recommended to verify install/uninstall information on a test device before deploying this worklet.

    NOTE: This worklet will attempt to locate the uninstall switches from the registry. If no switches are detected, the
    worklet will attempt use settings provided for $uninstallSwitchEXE. If this was not defined, the worklet will fail
    and report this in the Activity Log.

    Please check the software manufacturer's support documentation for administrative install/uninstall instructions.

    Usage: There are two variables that are used in this remediation script. These define the application name to target,
    and any specific command switches needed for EXE installations. User installations are supported by this worklet, and
    are handled via a scheduled task that is created, and removed, after uninstall completes.

    $appName: This is where you define the application name to be targeted. You can use a partial name, although be sure
    that it is unique enough to prevent accidental uninstalls of similarly named apps. Spaces are allowed, however do not
    use wildcards as they are already accounted for in the main body of the script.

    $uninstallSwitchEXE: This is where you will place the command switches needed to silently uninstall an application that
    was installed via an EXE installer. These switches will be used as a fallback if the worklet was unable to locate the
    switches from the registry key itself. If this variable was needed, and not defined, the worklet will send an error to
    the Activity Log regarding this.
.EXAMPLE
    EXE based (with switches defined)
    -----------------
    $appName = 'Python'
    $uninstallSwitchEXE = '/uninstall /quiet'
.EXAMPLE
    EXE based (with switches not defined)
    -----------------
    $appName = 'Slack'
    $uninstallSwitchEXE = ''
.EXAMPLE
    MSI based
    -----------------
    $appName = 'Adobe Acrobat Reader'
    $uninstallSwitchEXE = ''
.NOTES
    Updated Date: June 6, 2023
#>

####### Edit within this block #######
$appName = 'Java 8 Update 451 (64-bit)'
$uninstallSwitchEXE = ''
######################################

# Checks for installations in the 64bit hive on x64 devices
if([System.Environment]::Is64BitOperatingSystem)
{
    $hklm64 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,[Microsoft.Win32.RegistryView]::Registry64)
    $skey64 = $hklm64.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Uninstall")
    $unkeys64 = $skey64.GetSubKeyNames()
    foreach($key in $unkeys64)
    {
        if($skey64.OpenSubKey($key).getvalue('DisplayName') -like "*$appName*" -and !($skey64.OpenSubKey($key).getvalue("SystemComponent")))
        {
            if($skey64.OpenSubKey($key).getvalue("UninstallString") -like '*msiexec*')
            {
                try
                {
                    Start-Process -FilePath MSIExec.exe -ArgumentList "/x $key /qn /norestart /l*v $env:windir\temp\UninstallApp-64.log" -Wait
                }
                catch
                {
                    $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See logs at $env:windir\temp\UninstallApp64.log")
                    Exit 1603
                }
                $success += 1
            }
            else
            {
                try
                {
                    $64unString = $skey64.OpenSubKey($key).getvalue("UninstallString")
                    #clean up quoted paths
                    if($64unString.Contains('"'))
                    {
                        $64unString = $64unString.Replace('"','')
                    }
                    #attempt to capture switches
                    if($64unString -like '*/*' -or $64unString -like '*-*')
                    {
                        $64switch = $64unString.Split('.')[1]
                        $64switch = $64switch.Trim('exe ')
                        $64exePath = $64unString.Split('.')[0] + '.exe'

                        #Check $64switch in the event a hyphen exists in exe path and replace as needed
                        if($64switch.Length -lt '1')
                        {
                            if(!($uninstallSwitchEXE.Length -lt '1'))
                            {
                                $64switch = $uninstallSwitchEXE
                            }
                            else
                            {
                                $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                                Exit 87
                            }
                        }
                    }
                    else
                    {
                        #unable to locate switches. Check for Defined var
                        if(!($uninstallSwitchEXE.Length -lt '1'))
                        {
                            $64exePath = $64unString
                            $64switch = $uninstallSwitchEXE
                        }
                        else
                        {
                            $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                            Exit 87
                        }
                    }
                    Start-Process -FilePath $64exePath -ArgumentList $64switch -Wait
                }
                catch
                {
                    $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See uninstall logs if available.")
                    Exit 1603
                }
                $success += 1
            }
        }
    }
}

# Check for installations in the 32bit hive on x86/x64 devices
$skey32 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($key in Get-ChildItem $skey32 -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -like "*$appName*" -and !($_.SystemComponent))})
{
    if($key.UninstallString -like '*msiexec*')
    {
        try
        {
            $32keyName = $key.PSChildName
            Start-Process -FilePath MSIExec.exe -ArgumentList "/x $32keyName /qn /norestart /l*v $env:windir\temp\UninstallApp-32.log" -Wait
        }
        catch
        {
            $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See logs at $env:windir\temp\UninstallApp32.log")
            Exit 1603
        }
        $success += 1
    }
    else
    {
        try
        {
            $32unString = $key.UninstallString
            #clean up quoted paths
            if($32unString.Contains('"'))
            {
                $32unString = $32unString.Replace('"','')
            }
            #attempt to capture switches
            if($32unString -like '*/*' -or $32unString -like '*-*')
            {
                $32switch = $32unString.Split('.')[1]
                $32switch = $32switch.Trim('exe ')
                $32exePath = $32unString.Split('.')[0] + '.exe'

                #Check $32switch in the event a hyphen exists in exe path and replace as needed
                if($32switch.Length -lt '1')
                {
                    if(!($uninstallSwitchEXE.Length -lt '1'))
                    {
                        $32switch = $uninstallSwitchEXE
                    }
                    else
                    {
                        $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                        Exit 87
                    }
                }
            }
            else
            {
                #unable to locate switches. Check for Defined var
                if(!($uninstallSwitchEXE.Length -lt '1'))
                {
                    $32exePath = $32unString
                    $32switch = $uninstallSwitchEXE
                }
                else
                {
                    $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                    Exit 87
                }
            }
            Start-Process -FilePath $32exePath -ArgumentList $32switch -Wait
        }
        catch
        {
            $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See uninstall logs if available.")
            Exit 1603
        }
        $success += 1
    }
}

# Scan HKU for installed instance of $appname
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
foreach($usr in Get-ChildItem -Path "HKU:\")
{
    foreach($guid in Get-ChildItem "HKU:\$usr\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -like "*$AppName*" -and !($_.SystemComponent))})
    {
        if($guid.UninstallString -like '*msiexec*')
        {
            try
            {
                $usrKeyname = $guid.PSChildName
                Start-Process -FilePath MSIExec.exe -ArgumentList "/x $usrKeyname /qn /norestart /l*v $env:windir\temp\UninstallApp-Usr.log" -Wait
            }
            catch
            {
                $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See logs at $env:windir\temp\UninstallApp-Usr.log")
                Remove-PSDrive HKU
                Exit 1603
            }
            $success += 1
        }
        else
        {
            $usrUnstring = $guid.UninstallString
            #Clean up quoted paths
            if($usrUnstring.Contains('"'))
            {
                $usrUnstring = $usrUnstring.Replace('"','')
            }
            #Attempt to capture switches
            if($usrUnstring -like '*/*' -or $usrUnstring -like '*-*')
            {
                $usrSwitch = $usrUnstring.Split('.')[1]
                $usrSwitch = $usrSwitch.Trim('exe ')
                $usrExepath = $usrUnstring.Split('.')[0] + '.exe'

                #Check $usrSwitch in the event a hyphen exists in exe path and replace as needed
                if($usrSwitch.Length -lt '1')
                {
                    if(!($uninstallSwitchEXE.Length -lt '1'))
                    {
                        $usrSwitch = $uninstallSwitchEXE
                    }
                    else
                    {
                        $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                        Remove-PSDrive HKU
                        Exit 87
                    }
                }
            }
            else
            {
                #Unable to locate switches, check for defined var
                if(!($uninstallSwitchEXE.Length -lt '1'))
                {
                    $usrExepath = $usrUnstring
                    $usrSwitch = $uninstallSwitchEXE
                }
                else
                {
                    $host.UI.WriteErrorLine("ERROR: Uninstall switches not found. Please define uninstallSwitchEXE variable in this worklet.")
                    Remove-PSDrive HKU
                    Exit 87
                }
            }
            try
            {
                # Creates scheduled task to run in USER context and deletes task when done
                $schdService = New-Object -comobject 'Schedule.Service'
                $schdService.Connect()
                $Task = $schdService.NewTask(0)
                $Task.RegistrationInfo.Description = "Uninstall User App"
                $Task.Settings.Enabled = $true
                $Task.Settings.AllowDemandStart = $true
                $task.Settings.DisallowStartIfOnBatteries = $false
                $Task.Principal.RunLevel = 1
                $trigger = $task.triggers.Create(7)
                $trigger.Enabled = $true
                $action = $Task.Actions.Create(0)
                $action.Path = "$usrExePath"
                $action.Arguments = "$usrSwitch"
                $taskFolder = $schdService.GetFolder("\")
                $taskFolder.RegisterTaskDefinition("Uninstall User App", $Task , 6, "Users", $null, 4) | Out-Null

                DO
                {
                    (Get-ScheduledTask -TaskName 'Uninstall User App').State | Out-Null
                }
                Until ((Get-ScheduledTask -TaskName 'Uninstall User App').State -eq "Ready")
                Unregister-ScheduledTask 'Uninstall User App' -Confirm:$false
            }
            catch
            {
                $host.UI.WriteErrorLine("ERROR: Uninstall Failed - See uninstall logs if available.")
                Remove-PSDrive HKU
                Exit 1603
            }
            $success += 1
        }
    }
}
Remove-PSDrive HKU

# Check for success
if($success)
{
    Write-Output "Successfully uninstalled $success apps"
    Exit 0
}
Write-Output "No installations found"
Exit 0

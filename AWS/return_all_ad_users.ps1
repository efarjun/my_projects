# The following script returns all AD users in the domain.

$domain = "demantdev.com"
$ou = "OU=demantdev,DC=demantdev,DC=com"
$users = Get-ADUser -Filter * -SearchBase $ou -Server $domain -Properties SamAccountName

foreach ($user in $users) {
    $username = $user.SamAccountName
    Write-Host "$username"
}

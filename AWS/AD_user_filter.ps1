# This is a powershell script to retreive users in a domain with the word "test" in them.

$users = Get-ADUser -Filter * -Properties EmailAddress |
    Where-Object { $_.EmailAddress -like '*test*' } |
    Select-Object -ExpandProperty Name

$users

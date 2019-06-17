$Days = Read-Host -Prompt "Nombre de jours "
$When = (Get-Date).Adddays(-($Days))
Get-ADUser -Filter {whenCreated -ge $When} -Server groupe -Properties whenCreated, SamAccountName, DistinguishedName |Select-Object DistinguishedName, WhenCreated, Enabled |Export-Csv .\testcreateuser_groupe.csv -NoTypeInformation -Encoding UTF8
Get-ADUser -Filter {whenCreated -ge $When} -Server other -Properties whenCreated, SamAccountName, DistinguishedName |Select-Object DistinguishedName, WhenCreated, Enabled |Export-Csv .\testcreateuser_other.csv -NoTypeInformation -Encoding UTF8

$mina = Get-ADUser $env:USERNAME
$null = $mina.DistinguishedName -match '^CN=([^,]*),'
Get-ADUser -filter { Name -like $Matches[1] }

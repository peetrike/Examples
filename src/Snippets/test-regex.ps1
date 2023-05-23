$mina = Get-ADUser $env:USERNAME
$null = $mina.DistinguishedName -match '^CN=([^,]*),'
$RelativeName = $Matches[1]
Get-ADUser -filter { Name -like $RelativeName }

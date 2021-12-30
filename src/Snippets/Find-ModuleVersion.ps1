$ModulePath = $env:PSModulePath -split ';' |
    Where-Object { $_ -like "$env:ProgramFiles*" }

Get-ChildItem -Path $ModulePath\* -Include * -Directory |
    Group-Object Parent |
    Where-Object Count -gt 2

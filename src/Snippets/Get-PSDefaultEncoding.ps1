#Requires -Version 3

[psobject].Assembly.GetTypes() |
    Where-Object Name -eq 'ClrFacade' |
    ForEach-Object -MemberName GetMethod -ArgumentList 'GetDefaultEncoding', ([System.Reflection.BindingFlags]'nonpublic,static') |
    ForEach-Object -MemberName Invoke -ArgumentList $null, @()

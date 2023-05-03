#Requires -Version 2
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-LocalUser')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-WmiObject')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleTypes', '')]
[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

$Filter = 'LocalAccount=True'
$FilterDomain = 'Domain="{0}"' -f $env:COMPUTERNAME
$FilterSid = '{0} and Sid like "%-500"' -f $Filter
$ClassName = 'Win32_UserAccount'
$CimQuery = 'select Sid from {0} where {1}' -f $ClassName, $FilterSid

Add-Type -AssemblyName System.DirectoryServices.AccountManagement

$dotNet = {
    $localMachine = [DirectoryServices.AccountManagement.ContextType]::Machine
    $PrincipalContext = [DirectoryServices.AccountManagement.PrincipalContext] $localMachine
    $UserPrincipal = [DirectoryServices.AccountManagement.UserPrincipal] $PrincipalContext
    $searcher = [DirectoryServices.AccountManagement.PrincipalSearcher] $UserPrincipal
    $searcher.FindOne().Sid.AccountDomainSid
}
$Adsi = {
    $SidArray = ([adsi]"WinNT://$env:COMPUTERNAME/Administrator").ObjectSid.Value
    (
        New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $SidArray, 0
    ).AccountDomainSid
}
$Accelerator = {
    $Searcher = [wmisearcher] $CimQuery
    ([Security.Principal.SecurityIdentifier]$Searcher.Get().Sid).AccountDomainSid
}
$Wmi = {
    $Object = (Get-WmiObject -Class $ClassName -Filter $Filter)[0]
    ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
}
$WmiSid = {
    $Object = Get-WmiObject -Class $ClassName -Filter $FilterSid
    ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique = @{
        '.Net'          = $dotNet
        'ADSI'          = $Adsi
        'Accelerator'   = $Accelerator
        'Cim'           = {
            $Object = (Get-CimInstance -ClassName $ClassName -Filter $Filter)[0]
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'cim w/ domain' = {
            $Object = (Get-CimInstance -ClassName $ClassName -Filter $FilterDomain)[0]
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Sid'    = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $FilterSid
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Props'  = {
            $Object = Get-CimInstance -Query $CimQuery
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
    }

    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        $Technique += @{
            'LocalUser' = {
                (Get-LocalUser | Select-Object -First 1).Sid.AccountDomainSid
            }
        }
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $Technique += @{
            'WMI'        = $Wmi
            'WMI w/ Sid' = $WmiSid
        }
    }
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

   @(
        Measure-ScriptBlock -Method '.NET' -Iterations $Max -ScriptBlock $DotNet
        Measure-ScriptBlock -Method 'ADSI' -Iterations $Max -ScriptBlock $Adsi
        Measure-ScriptBlock -Method 'Accelerator' -Iterations $Max -ScriptBlock $Accelerator
        Measure-ScriptBlock -Method 'WMI' -Iterations $Max -ScriptBlock $Wmi
        Measure-ScriptBlock -Method 'WMI w/ Sid' -Iterations $Max -ScriptBlock $WmiSid
    ) | Sort-Object TotalMilliseconds
}

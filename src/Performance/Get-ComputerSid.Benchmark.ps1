#Requires -Version 3
#Requires -Module BenchPress

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

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        '.Net'          = {
            $localMachine = [DirectoryServices.AccountManagement.ContextType]::Machine
            $PrincipalContext = [DirectoryServices.AccountManagement.PrincipalContext] $localMachine
            $UserPrincipal = [DirectoryServices.AccountManagement.UserPrincipal] $PrincipalContext
            $searcher = [DirectoryServices.AccountManagement.PrincipalSearcher] $UserPrincipal
            $searcher.FindOne().Sid.AccountDomainSid
        }
        'ADSI'          = {
            $SidArray = ([adsi]"WinNT://$env:COMPUTERNAME/Administrator").ObjectSid.Value
            ([Security.Principal.SecurityIdentifier]::new($SidArray, 0)).AccountDomainSid
        }
        'LocalUser'     = {
            (Get-LocalUser | select -First 1).Sid.AccountDomainSid
        }
        'Cim'           = {
            $Object = (Get-CimInstance -ClassName $ClassName -Filter $Filter)[0]
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'cim w/ select' = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $Filter | Select-Object -First 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Sid'    = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $FilterSid
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'cim w/ domain' = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $FilterDomain | Select-Object -First 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Props'  = {
            $Object = Get-CimInstance -query $CimQuery #| Select-Object -First 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Accelerator'   = {
            $Searcher = [wmisearcher] $CimQuery
            ([Security.Principal.SecurityIdentifier]$Searcher.Get().Sid).AccountDomainSid
        }
    } -GroupName ('Time only: {0} times' -f $iterations)
}

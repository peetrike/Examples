#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 100
)

$Filter = 'LocalAccount=True'
$FilterDomain = 'Domain="{0}"' -f $env:COMPUTERNAME
$FilterSid = 'LocalAccount=True and Sid like "%-500"'
$ClassName = 'Win32_UserAccount'
$CimQuery = 'select Sid from Win32_UserAccount where LocalAccount=True and Sid like "%-500"'

Add-Type -AssemblyName System.DirectoryServices.AccountManagement

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'LocalUser'  = {
            (Get-LocalUser | select -First 1).Sid.AccountDomainSid
        }
        'Cim'           = {
            $Object = (Get-CimInstance -ClassName $ClassName -Filter $Filter)[0]
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Sid'    = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $FilterSid
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'cim w/ domain' = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $FilterDomain | select -first 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'cim w/ select' = {
            $Object = Get-CimInstance -ClassName $ClassName -Filter $Filter | select -first 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'Cim w/ Props'  = {
            $Object = Get-CimInstance -query $CimQuery | select -first 1
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'ADSI'          = {
            $SidArray = ([adsi]"WinNT://$env:COMPUTERNAME/Administrator").ObjectSid.Value
            ([Security.Principal.SecurityIdentifier]::new($SidArray, 0)).AccountDomainSid
        }
        <# '.Net'       = {
            $localMachine = [DirectoryServices.AccountManagement.ContextType]::Machine
            $PrincipalContext = [DirectoryServices.AccountManagement.PrincipalContext]$localMachine
            $UserPrincipal = New-Object -TypeName 'DirectoryServices.AccountManagement.UserPrincipal' -ArgumentList $PrincipalContext
            $searcher = New-Object -TypeName 'DirectoryServices.AccountManagement.PrincipalSearcher' -ArgumentList $UserPrincipal
            $searcher.FindOne()
        } #>
    } -GroupName ('Time only: {0} times' -f $iterations)
}

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

function Get-ComputerSid {
    [OutputType([Security.Principal.SecurityIdentifier])]
    [CmdletBinding()]
    param ()

    # Prepare the P/Invoke signature
    try {
        $null = [Windows.Identity.Win32API+SidType]::SidTypeComputer
    } catch {
        Add-Type -TypeDefinition @'
        using System;
        using System.Runtime.InteropServices;
        using System.Text;

        namespace Windows.Identity {
            public class Win32API {
                public enum SidType {
                    SidTypeUser = 1,
                    SidTypeGroup,
                    SidTypeDomain,
                    SidTypeAlias,
                    SidTypeWellKnownGroup,
                    SidTypeDeletedAccount,
                    SidTypeInvalid,
                    SidTypeUnknown,
                    SidTypeComputer
                }

                [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                public static extern bool LookupAccountName(
                    string lpSystemName,
                    string lpAccountName,
                    byte[] Sid,
                    ref uint cbSid,
                    StringBuilder ReferencedDomainName,
                    ref uint cchReferencedDomainName,
                    out SidType peUse);
            }
        }
'@
    }

    # Prepare the parameters
    $sidLength = 24
    $sid = New-Object byte[] $sidLength
    $accountName = $env:COMPUTERNAME
    $domainNameLength = $accountName.Length + 1
    $domainName = New-Object System.Text.StringBuilder $domainNameLength
    $use = [Windows.Identity.Win32API+SidType]::SidTypeComputer

    # Call the function to get SID
    $result = [Windows.Identity.Win32API]::LookupAccountName(
        $null,
        $accountName,
        $sid,
        [ref] $sidLength,
        $domainName,
        [ref] $domainNameLength,
        [ref] $use
    )

    if ($result) {
        # Convert the byte array SID to a string SID
        New-Object -TypeName Security.Principal.SecurityIdentifier -ArgumentList $sid, 0
    } else {
        $Message = 'LookupAccountName failed with error code: {0}' -f
            [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        Write-Error -Message $Message -ErrorAction Stop
    }
}

$Filter = 'LocalAccount=True'
$FilterDomain = 'Domain="{0}"' -f $env:COMPUTERNAME
$FilterSid = '{0} and Sid like "%-500"' -f $Filter
$ClassName = 'Win32_UserAccount'
$CimQuery = 'select Sid from {0} where {1}' -f $ClassName, $FilterSid
$GenericQuery = 'select * from {0} where {1}' -f $ClassName, $Filter

Add-Type -AssemblyName System.DirectoryServices.AccountManagement

function Get-AdminName {
    $Searcher = [wmisearcher] ('select * from {0} where {1}' -f $ClassName, $FilterSid)
    $Searcher.Get() | Select -First 1 -ExpandProperty Name
}
$AdminName = Get-AdminName


$Technique = @{
    'Win32 API'          = {
        Get-ComputerSid
    }
    '.Net'               = {
        $localMachine = [DirectoryServices.AccountManagement.ContextType]::Machine
        $PrincipalContext = [DirectoryServices.AccountManagement.PrincipalContext] $localMachine
        $UserPrincipal = [DirectoryServices.AccountManagement.UserPrincipal] $PrincipalContext
        $searcher = [DirectoryServices.AccountManagement.PrincipalSearcher] $UserPrincipal
        $searcher.FindOne().Sid.AccountDomainSid
    }
    'ADSI'               = {
        $SidArray = ([adsi]"WinNT://$env:COMPUTERNAME/$AdminName").ObjectSid.Value
        (
            New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $SidArray, 0
        ).AccountDomainSid
    }
    'Accelerator w/ Sid' = {
        $Account = ([wmisearcher] $CimQuery).Get() | Select-Object -First 1
        ([Security.Principal.SecurityIdentifier]$Account.Sid).AccountDomainSid
    }
    'Accelerator'        = {
        $Account = ([wmisearcher] $GenericQuery).Get() |
            Select-Object -First 1
        ([Security.Principal.SecurityIdentifier]$Account.Sid).AccountDomainSid
    }

}

if ($PSVersionTable.PSVersion.Major -lt 6) {
    $Technique += @{
        'WMI'        = {
            $Object = (Get-WmiObject -Class $ClassName -Filter $Filter)[0]
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
        'WMI w/ Sid' = {
            $Object = Get-WmiObject -Class $ClassName -Filter $FilterSid
            ([Security.Principal.SecurityIdentifier]$Object.Sid).AccountDomainSid
        }
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
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

    if ($PSVersionTable.PSVersion.Major -gt 4) {
        $Technique += @{
            'LocalUser' = {
                (Get-LocalUser | Select-Object -First 1).Sid.AccountDomainSid
            }
        }
    }
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Iterations $Max -Technique $Technique
}

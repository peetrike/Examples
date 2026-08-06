#Requires -Version 2
# Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 1,
    $Max = 100
)

function Test-IsADJoined {
    [OutputType([bool])]
    [CmdletBinding()]
    param ()

    # Prepare the P/Invoke signature
    try {
        $null = [Windows.Identity.NetJoinStatus]
    } catch {
        Add-Type -TypeDefinition @'
        using System;
        using System.Runtime.InteropServices;

        namespace Windows.Identity {
            public enum NetJoinStatus {
                NetSetupUnknownStatus = 0,
                NetSetupUnjoined,
                NetSetupWorkgroupName,
                NetSetupDomainName
            }

            public class AD {
                [DllImport("Netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
                public static extern int NetGetJoinInformation(
                    string server,
                    out IntPtr domain,
                    out NetJoinStatus status);

                [DllImport("Netapi32.dll")]
                public static extern int NetApiBufferFree(IntPtr Buffer);
            }
        }
'@
    }

    $domain = [IntPtr]::Zero
    $status = [Windows.Identity.NetJoinStatus]::NetSetupUnknownStatus
    try {
        $result = [Windows.Identity.AD]::NetGetJoinInformation(
            $null,
            [ref] $domain,
            [ref] $status
        )
        if ($result -eq 0) {
            if ($status -gt [Windows.Identity.NetJoinStatus]::NetSetupUnjoined) {
                $target = switch ($status) {
                    ([Windows.Identity.NetJoinStatus]::NetSetupWorkgroupName) { 'Workgroup' }
                    ([Windows.Identity.NetJoinStatus]::NetSetupDomainName) { 'Domain' }
                }
                $name = [Runtime.InteropServices.Marshal]::PtrToStringUni($domain)
                Write-Verbose -Message ('{0} Name: {1}' -f $target, $name)
            }
            $status -eq [Windows.Identity.NetJoinStatus]::NetSetupDomainName
        }
    } catch {
        throw
    } finally {
        if ($domain -ne [IntPtr]::Zero) {
            $null = [Windows.Identity.AD]::NetApiBufferFree($domain)
        }
    }
}

$Technique = @{
    'Win32 API'               = {
        Test-IsADJoined
    }
    '.NET'                    = {
        try {
            [bool] [DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        } catch {
            $false
        }
    }
    'PartOfDomain A'          = {
        $Property = 'PartOfDomain'
        ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").$Property
    }
    'PartOfDomain specific S' = {
        $Property = 'PartOfDomain'
        ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
    }
    'PartOfDomain generic S'  = {
        $Property = 'PartOfDomain'
        ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty $Property
    }
    'DomainRole Specific S'   = {
        $Property = 'DomainRole'
        $Role = ([wmisearcher] "SELECT $Property FROM Win32_ComputerSystem").Get() |
            Select-Object -ExpandProperty $Property
        0, 2 -notcontains $Role
    }
    'DomainRole Generic S'    = {
        $Property = 'DomainRole'
        $Role = ([wmisearcher] 'SELECT * FROM Win32_ComputerSystem').Get() |
            Select-Object -ExpandProperty $Property
        0, 2 -notcontains $Role
    }
    'DomainRole A'            = {
        $Property = 'DomainRole'
        $Role = ([wmi] "Win32_ComputerSystem='$env:COMPUTERNAME'").$Property
        0, 2 -notcontains $Role
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
param (
    $Min = 1,
    $Max = 10
)

Add-Type -AssemblyName System.ServiceProcess

$Technique = @{
    'Get-Service | Where' = {
        $null = Get-Service | Where-Object { $_.Name -like "Bits" }
    }
    'Get-Service'         = {
        $null = Get-Service "Bits"
    }
    '.NET | Where'        = {
        $null = [ServiceProcess.ServiceController]::GetServices() | Where-Object { $_.Name -like 'bits' }
    }
    '.NET direct'         = {
        $null = [ServiceProcess.ServiceController] @{ Name = 'bits' }
    }
}

if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
    $Technique += @{
        'GCIM'      = {
            $null = Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
        }
        'GCIM full' = {
            $null = Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'"
        }
    }
}

if ($PSVersionTable.PSVersion.Major -le 5) {
    $Technique += @{
        'GWMI'      = {
            $null = Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
        }
        'GWMI full' = {
            $null = Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'"
        }
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

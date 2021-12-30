#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
param (
    $Min = 1,
    $Max = 10
)

Add-Type -AssemblyName System.ServiceProcess

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
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
    } -GroupName ('PS all: {0} times' -f $iterations)

    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        Measure-Benchmark -RepeatCount $iterations -Technique @{
            'GCIM'      = {
                $null = Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
            }
            'GCIM full' = {
                $null = Get-CimInstance -ClassName Win32_Service -Filter "Name = 'BITS'"
            }
        } -GroupName ('PS > 2: {0} times' -f $iterations)
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        Measure-Benchmark -RepeatCount $iterations -Technique @{
            'GWMI'      = {
                $null = Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'" -Property Name, PathName
            }
            'GWMI full' = {
                $null = Get-WmiObject -Class Win32_Service -Filter "Name = 'BITS'"
            }
        } -GroupName ('PS < 6: {0} times' -f $iterations)
    }
}

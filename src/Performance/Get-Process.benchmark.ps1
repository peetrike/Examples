#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
param (
    $Min = 1,
    $Max = 10
)

$Technique = @{
    'Get-Process' = {
        $null = (Get-Process -id $PID).Name
    }
    '.NET direct' = {
        $null = [Diagnostics.Process]::GetCurrentProcess().Name
    }
}

if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
    $Technique += @{
        'GCIM'      = {
            $null = (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
        }
        'GCIM full' = {
            $null = (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID").Name
        }
    }
}

if ($PSVersionTable.PSVersion.Major -le 5) {
    $Technique += @{
        'GWMI'      = {
            $null = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID" -Property Name).Name
        }
        'GWMI full' = {
            $null = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $PID").Name
        }
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

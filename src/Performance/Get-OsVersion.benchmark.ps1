#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Get-WmiObject')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
param (
    $Min = 1,
    $Max = 100
)


$Technique = @{
    'GCIM only version' = {
        [Version] (Get-CimInstance -ClassName Win32_OperatingSystem -Property Version).Version
    }
    'GCIM full'         = {
        [Version] (Get-CimInstance -ClassName Win32_OperatingSystem).Version
    }
    'Accelerator'       = {
        [Version] ([wmi] 'Win32_OperatingSystem=@').Version
    }
    '.NET'              = {
        [System.Environment]::OSVersion.Version
    }
}

if ($PSVersionTable.PSVersion.Major -le 5) {
    $Technique += @{
        'GWMI full'         = {
            [Version] (Get-WmiObject -ClassName Win32_OperatingSystem).Version
        }
        'GWMI only version' = {
            [Version] (Get-WmiObject -Class Win32_OperatingSystem -Property Version).Version
        }
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

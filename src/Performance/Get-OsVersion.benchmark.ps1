#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCmdLets', 'Get-CimInstance')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '')]
param (
    $Min = 1,
    $Max = 100
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'GWMI full'         = {
            [Version] (Get-WmiObject -ClassName Win32_OperatingSystem).Version
        }
        'GWMI only version' = {
            [Version] (Get-WmiObject -Class Win32_OperatingSystem -Property Version).Version
        }
        'GCIM only version' = {
            [Version] (Get-CimInstance -ClassName Win32_OperatingSystem -Property Version).Version
        }
        'GCIM full'         = {
            [Version] (Get-CimInstance -ClassName Win32_OperatingSystem).Version
        }
        '.NET'              = {
            [System.Environment]::OSVersion.Version
        }
    } -GroupName ('{0} times' -f $iterations)
}

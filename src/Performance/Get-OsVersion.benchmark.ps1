#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 1000
)


for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'GWMI full' = {
            [Version] (Get-WmiObject -ClassName Win32_OperatingSystem).Version
        }
        'GWMI only version' = {
            [Version] (Get-WmiObject -Class Win32_OperatingSystem -Property Version).Version
        }
        'GCIM only version' = {
            [Version] (Get-CimInstance -ClassName Win32_OperatingSystem -Property Version).Version
        }
        '.NET' = {
            [System.Environment]::OSVersion.Version
        }
    } -GroupName ('{0} times' -f $iterations)
}

#Requires -Version 3.0
#Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
param (
    $Min = 10,
    $Max = 10000
)

$PropertyList = 'CSName', 'TotalVisibleMemorySize', 'FreePhysicalMemory'
$BaseObject = Get-CimInstance Win32_OperatingSystem
$PercentMemory = $BaseObject.FreePhysicalMemory / $BaseObject.TotalVisibleMemorySize

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Iterations -Technique @{
        'Add-Member'    = {
            $result = $BaseObject |
                Select-Object -Property $PropertyList |
                Add-Member -MemberType NoteProperty -Name '%Free' -Value $PercentMemory -PassThru
        }
        'Select-Object' = {
            $PercentProperty = @{
                Name       = '%Free'
                Expression = { $PercentMemory }
            }
            $result = $BaseObject | Select-Object -Property ($PropertyList + $PercentProperty)
        }
        'New Object'    = {
            $ObjectProps = @{
                '%Free' = $PercentMemory
            }
            foreach ($p in $PropertyList) {
                $ObjectProps.$p = $BaseObject.$p
            }
            $result = [pscustomobject] $ObjectProps
        }
    } -GroupName $Iterations
}

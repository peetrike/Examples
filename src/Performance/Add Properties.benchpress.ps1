#Requires -Version 2.0
# Requires -Module BenchPress

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'result')]
param (
    $Min = 10,
    $Max = 10000
)

$newer = $PSVersionTable.PSVersion.Major -gt 2

$PropertyList = 'CSName', 'TotalVisibleMemorySize', 'FreePhysicalMemory'
$BaseObject = [wmi] 'Win32_OperatingSystem=@'
$PercentMemory = 100 * $BaseObject.FreePhysicalMemory / $BaseObject.TotalVisibleMemorySize

$Technique = @{
    'Add-Member'    = {
        $BaseObject = $BaseObject
        $PercentMemory = $PercentMemory
        $PropertyList = $PropertyList

        $result = $BaseObject |
            Select-Object -Property $PropertyList |
            Add-Member -MemberType NoteProperty -Name '%Free' -Value $PercentMemory -PassThru
    }
    'Select-Object' = {
        $BaseObject = $BaseObject
        $PercentMemory = $PercentMemory
        $PropertyList = $PropertyList

        $PercentProperty = @{
            Name       = '%Free'
            Expression = { $PercentMemory }
        }
        $result = $BaseObject | Select-Object -Property ($PropertyList + $PercentProperty)
    }
    'New Object'    = {
        $BaseObject = $BaseObject
        $PercentMemory = $PercentMemory
        $PropertyList = $PropertyList

        $ObjectProps = @{
            '%Free' = $PercentMemory
        }
        foreach ($p in $PropertyList) {
            $ObjectProps.$p = $BaseObject.$p
        }
        $result = if ($newer) {
            [pscustomobject] $ObjectProps
        } else {
            New-Object -TypeName psobject -Property $ObjectProps
        }
    }
}

if ($newer) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $Iterations -Technique $Technique -GroupName $Iterations
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $max -ScriptBlock $Technique.$key
    }
}

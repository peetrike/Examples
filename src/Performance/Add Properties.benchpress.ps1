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

$Technique = @{
    'Add-Member'    = {
        $BaseObject = $BaseObject
        $PropertyList = $PropertyList
        $PercentMemory = { 100 * $this.FreePhysicalMemory / $this.TotalVisibleMemorySize }

        $result = $BaseObject |
            Select-Object -Property $PropertyList |
            Add-Member -MemberType ScriptProperty -Name '%Free' -Value $PercentMemory -PassThru
    }
    'Select-Object' = {
        $BaseObject = $BaseObject
        $PropertyList = $PropertyList

        $PercentProperty = @{
            Name       = '%Free'
            Expression = { 100 * $_.FreePhysicalMemory / $_.TotalVisibleMemorySize }
        }
        $result = $BaseObject | Select-Object -Property ($PropertyList + $PercentProperty)
    }
    'New Object'    = {
        $BaseObject = $BaseObject
        $PropertyList = $PropertyList
        $PercentMemory = 100 * $BaseObject.FreePhysicalMemory / $BaseObject.TotalVisibleMemorySize
        $TypeName = 'System.Management.ManagementObject#root\cimv2\Win32_OperatingSystem'

        $ObjectProps = @{
            '%Free' = $PercentMemory
        }
        foreach ($p in $PropertyList) {
            $ObjectProps.$p = $BaseObject.$p
        }
        $result = if ($newer) {
            $ObjectProps.PSTypeName = $TypeName
            [pscustomobject] $ObjectProps
        } else {
            $o = New-Object -TypeName psobject -Property $ObjectProps
            $o.psobject.TypeNames.Insert(0, $TypeName)
            $o
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

    Measure-ScriptBlock -Iterations $max -Technique $Technique
}

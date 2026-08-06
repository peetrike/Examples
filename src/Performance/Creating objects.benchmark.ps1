#Requires -Version 2
# Requires -Module BenchPress

<#
    .SYNOPSIS
        Object creation benchmark test
    .DESCRIPTION
        This script measures speed of various object creation methods
    .LINK
        https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_object_creation
    .LINK
        https://learn.microsoft.com/previous-versions/powershell/module/microsoft.powershell.core/about/about_object_creation?view=powershell-3.0
    .LINK
        https://devblogs.microsoft.com/powershell/new-v3-language-features/
#>


[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'list')]
[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$Technique = @{
    'New-Object -Property' = {
        $o = New-Object -TypeName psobject -Property @{
            Message = 'text'
            Count   = 3
            Date    = [datetime]::Now
        }
        $o.psobject.TypeNames.Insert(0, 'MyCustom')
        $o
    }
    'Select-Object'        = {
        $o = New-Object -TypeName psobject
        $o = $o | Select-Object @{
            Name       = 'Message'
            Expression = { 'text' }
        }, @{
            Name       = 'Count'
            Expression = { 3 }
        }, @{
            Name       = 'Date'
            Expression = { [datetime]::Now }
        }
        $o.psobject.TypeNames.Insert(0, 'MyCustom')
        $o
    }

    'Add-Member w/ pipe'   = {
        $o = New-Object PSObject |
            Add-Member -MemberType NoteProperty -Name Message -Value text -PassThru |
            Add-Member -MemberType NoteProperty -Name Count -Value 3 -PassThru |
            Add-Member -MemberType NoteProperty -Name Date -Value ([datetime]::Now) -PassThru
        $o.psobject.TypeNames.Insert(0, 'MyCustom')
        $o
    }
    'Add-Member w/o pipe'  = {
        $o = New-Object PSObject
        Add-Member -InputObject $o -MemberType NoteProperty -Name Message -Value text
        Add-Member -InputObject $o -MemberType NoteProperty -Name Count -Value 3
        Add-Member -InputObject $o -MemberType NoteProperty -Name Date -Value ([datetime]::Now)
        $o.psobject.TypeNames.Insert(0, 'MyCustom')
        $o
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'PSCustomObject' = {
            [PSCustomObject] @{
                PSTypeName = 'MyCustom'
                Message    = 'text'
                Count      = 3
                Date       = [datetime]::Now
            }
        }
        'Add-Member PS3' = {
            New-Object PSObject |
                Add-Member -NotePropertyName Message -NotePropertyValue text -PassThru |
                Add-Member -NotePropertyName Date -NotePropertyValue ([datetime]::Now) -PassThru |
                Add-Member -NotePropertyName Count -NotePropertyValue 3 -TypeName 'MyCustom' -PassThru
        }
    }

    if ($PSVersionTable.PSVersion.Major -gt 4) {
        $Technique += @{
            'PSObject new()'   = {
                $o = [psobject]::new()
                $o.psobject.Properties.Add([PSNoteProperty]::new('Message', 'text'))
                $o.psobject.Properties.Add([PSNoteProperty]::new('Count', 3))
                $o.psobject.Properties.Add([PSNoteProperty]::new('Date', [datetime]::Now))
                $o.psobject.TypeNames.Insert(0, 'MyCustom')
                $o
            }
            'Add-Member multi' = {
                New-Object PSObject |
                    Add-Member -TypeName 'MyCustom' -NotePropertyMembers @{
                        Message = 'text'
                        Count   = 3
                        Date    = [datetime]::Now
                    } -PassThru
            }
        }
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $Iterations -Technique $Technique -GroupName $Iterations
}

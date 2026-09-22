#Requires -Version 2
# Requires -Modules BenchPress

<#PSScriptInfo
    .VERSION 3.52.140

    .GUID cbd007e6-bc81-46e5-b4f4-09b24b389da5
    .AUTHOR Peter Wawa
#>

<#
    .DESCRIPTION
        Benchmark different techniques for searching file content.
#>


param (
    $Min = 10,
    $Max = 1000
)

$FileName = $MyInvocation.MyCommand.Path
$Pattern = '\.VERSION\s+(\d+(?:\.\d+){1,3})$'

$Technique = @{
    'switch'          = {
        switch -Regex -File $FileName {
            $Pattern {
                [version] $Matches[1]
            }
        }
    }
    'switch w/ break' = {
        switch -Regex -File $FileName {
            $Pattern {
                [version] $Matches[1]
                break
            }
        }
    }
    'Select-String'   = {
        $result = Select-String -Path $fileName -Pattern $Pattern
        [version] $result.Matches.Groups[1].Value
    }
    '-match'          = {
        foreach ($line in Get-Content -Path $fileName) {
            if ($line -match $Pattern) {
                [version] $Matches[1]
                break
            }
        }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
} elseif ($PSVersionTable.PSVersion.Major -ge 5) {
    $Technique.cmdlet = {
        $result = Test-ScriptFileInfo -Path $fileName
        $result.version
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

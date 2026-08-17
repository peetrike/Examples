#Requires -Version 2
# Requires -Modules BenchPress

<#PSScriptInfo
    .VERSION 3.52.140
#>


param (
    $Min = 10,
    $Max = 1000
)

$FileName = $MyInvocation.MyCommand.Path
$Pattern = '\.VERSION\s+(\d+(?:\.\d+){1,3})$'

$Technique = @{
    'switch'        = {
        switch -Regex -File $FileName {
            $Pattern {
                [version] $Matches[1]
            }
        }
    }
    'Select-String' = {
        $result = Select-String -Path $fileName -Pattern $Pattern
        [version] $result.Matches.Groups[1].Value
    }
    '-match'        = {
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
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

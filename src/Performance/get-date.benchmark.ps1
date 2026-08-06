#Requires -Version 2.0
# Requires -Module BenchPress

param (
    $Min = 1000,
    $Max = 10000
)

$TimeTechnique = @{
    '.Net generic'      = { '{0:T}' -f [datetime]::Now }
    '.Net specific'     = { '{0:HH\:mm\:ss}' -f [datetime]::Now }
    'ToString generic'  = { [datetime]::Now.ToString('T') }
    'ToString specific' = { [datetime]::Now.ToString('HH:mm:ss') }
    'Format generic'    = { Get-Date -Format T }
    'Format specific'   = { Get-Date -Format 'HH:mm:ss' }
    'Format Unix g'     = { Get-Date -UFormat '%T' }
    'Format Unix s'     = { Get-Date -UFormat '%H:%M:%S' }
    'DisplayHint'       = { Get-Date -DisplayHint Time }
}

$DateTechnique = @{
    '.Net now'          = { '{0:d}' -f [datetime]::Now }
    '.Net today'        = { '{0:d}' -f [datetime]::Today }
    'ToString specific' = { [datetime]::Today.ToString('dd.MM.yyyy') }
    'ToString generic'  = { [datetime]::Today.ToString('d') }
    'Format specific'   = { Get-Date -Format 'dd.MM.yyyy' }
    'Format generic'    = { Get-Date -Format d }
    'Format Unix s'     = { Get-Date -UFormat '%d.%m.%Y' }
    'Format Unix g'     = { Get-Date -UFormat '%x' }
}

$BothTechnique = @{
    '.Net ISO'            = { '{0:o}' -f [datetime]::Now }
    '.Net sortable'       = { '{0:s}' -f [datetime]::Now }
    'ToString sortable'   = { [datetime]::Now.ToString('s') }
    'ToString ISO'        = { [datetime]::Now.ToString('o') }
    'cmdlet FileDateTime' = { Get-Date -Format FileDateTime }
    'cmdlet sortable'     = { Get-Date -Format s }
    'cmdlet Unix s'       = { Get-Date -UFormat '%Y.%m.%d' }
    'cmdlet Unix g'       = { Get-Date -UFormat '%x' }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $TimeTechnique -GroupName "Time only: $iterations times"
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $DateTechnique -GroupName "Date only: $iterations times"
    }

    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        $GroupName = "File DateTime: $iterations times"
        Measure-Benchmark -RepeatCount $iterations -Technique $BothTechnique -GroupName $GroupName
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    $GroupName = "File DateTime: $Max times"
    Measure-ScriptBlock -Iterations $Max -Technique $BothTechnique -GroupName $GroupName
}

﻿#Requires -Module BenchPress

param (
    $Min = 1000,
    $Max = 10000
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        '.Net generic'      = { '{0:T}' -f [datetime]::Now }
        '.Net specific'     = { '{0:HH\:mm\:ss}' -f [datetime]::Now }
        'ToString generic'  = { [datetime]::Now.ToString('T') }
        'ToString specific' = { [datetime]::Now.ToString('HH:mm:ss') }
        'Format generic'    = { Get-Date -Format T }
        'Format specific'   = { Get-Date -Format 'HH:mm:ss' }
        'Format Unix g'     = { Get-Date -UFormat '%T' }
        'Format Unix s'     = { Get-Date -UFormat '%H:%M:%S' }
        'DisplayHint'       = { Get-Date -DisplayHint Time }
    } -GroupName ('Time only: {0} times' -f $iterations)
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        '.Net today'        = { '{0:d}' -f [datetime]::Today }
        '.Net now'          = { '{0:d}' -f [datetime]::Now }
        'ToString specific' = { [datetime]::Today.ToString('dd.MM.yyyy') }
        'ToString generic'  = { [datetime]::Today.ToString('d') }
        'Format specific'   = { Get-Date -Format 'dd.MM.yyyy' }
        'Format generic'    = { Get-Date -Format d }
        'Format Unix s'     = { Get-Date -UFormat '%d.%m.%Y' }
        'Format Unix g'     = { Get-Date -UFormat '%x' }
    } -GroupName ('Date only: {0} times' -f $iterations)
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        '.Net now'            = { '{0:yyyy-MM-dd}' -f [datetime]::Now }
        '.Net today'          = { '{0:yyyy-MM-dd}' -f [datetime]::Today }
        'ToString sortable'   = { [datetime]::Now.ToString('s') }
        'ToString ISO'        = { [datetime]::Now.ToString('o') }
        'cmdlet FileDateTime' = { Get-Date -Format FileDateTime }
        'cmdlet sortable'     = { Get-Date -Format s }
        'cmdlet Unix s'       = { Get-Date -UFormat '%Y.%m.%d' }
        'cmdlet Unix g'       = { Get-Date -UFormat '%x' }
    } -GroupName ('File DateTime: {0} times' -f $iterations)
}

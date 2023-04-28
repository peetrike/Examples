#Requires -Version 2
# Requires -Modules BenchPress

param (
    $Min = 100,
    $Max = 10000
)

$v2Foreach = {
    @(
        [Management.Automation.Internal.CommonParameters].GetProperties()
        [Management.Automation.Internal.ShouldProcessParameters].GetProperties()
        [Management.Automation.Internal.TransactionParameters].GetProperties()
    ) | ForEach-Object { $_.Name }
}
$v2Select = {
    @(
        [Management.Automation.Internal.CommonParameters].GetProperties()
        [Management.Automation.Internal.ShouldProcessParameters].GetProperties()
        [Management.Automation.Internal.TransactionParameters].GetProperties()
    ) | Select-Object -ExpandProperty Name
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique @{
            'PSCmdLet'   = {
                [Management.Automation.PSCmdlet]::CommonParameters,
                [Management.Automation.PSCmdlet]::OptionalCommonParameters
            }
            'Internal'   = {
                @(
                    [Management.Automation.Internal.CommonParameters].GetProperties().Name
                    [Management.Automation.Internal.ShouldProcessParameters].GetProperties().Name
                    [Management.Automation.Internal.TransactionParameters].GetProperties().Name
                )
            }
            'V2 Foreach' = $v2Foreach
            'V2 Select'  = $v2Select
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    Measure-ScriptBlock -Method 'Foreach' -Iterations $Max -ScriptBlock $v2Foreach
    Measure-ScriptBlock -Method 'Select' -Iterations $Max -ScriptBlock $v2Select
}

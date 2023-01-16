#Requires -Modules BenchPress

param (
    $Min = 100,
    $Max = 10000
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'PSCmdLet' = {
            [System.Management.Automation.pscmdlet]::CommonParameters,
            [System.Management.Automation.pscmdlet]::OptionalCommonParameters
        }
        'Internal' = {
            @(
                [System.Management.Automation.Internal.CommonParameters].GetProperties().Name
                [System.Management.Automation.Internal.ShouldProcessParameters].GetProperties().Name
                [System.Management.Automation.Internal.TransactionParameters].GetProperties().Name
            )
        }
    } -GroupName ('{0} times' -f $iterations)
}

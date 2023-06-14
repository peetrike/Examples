function Measure-ScriptBlock {
    param (
            [int]
        $Iterations = 10000,
            [string]
        $Method,
            [scriptblock]
        $ScriptBlock
    )

    $Type = @{
        Name       = 'Method'
        Expression = { $Method }
    }

    $Value = @{
        Name       = 'Time'
        Expression = { $_.ToString() }
    }
    $Throughput = @{
        Name       = 'Throughput'
        Expression = { '{0:N2}/s' -f ($Iterations / $_.TotalSeconds) }
    }

    1..$Iterations |
        Measure-Command $ScriptBlock |
        Select-Object -Property $Type, $Value, $Throughput
}

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
        Name       = 'TimeSpan'
        Expression = { $_.ToString() }
    }

    1..$Iterations |
        Measure-Command $ScriptBlock |
        Select-Object -Property $Type, $Value, TotalMilliseconds
}

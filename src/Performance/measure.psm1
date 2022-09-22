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

    1..$Iterations |
        Measure-Command $ScriptBlock |
        Select-Object -Property $Type, TotalMilliseconds
}

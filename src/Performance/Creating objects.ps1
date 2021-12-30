#Requires -Version 3.0

$Iterations = 10000

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
        Name       ='Method'
        Expression = { $Method }
    }

    1..$Iterations |
        Measure-Command $ScriptBlock |
        Select-Object -Property TotalMilliseconds, $Type
}

#region New-Object
$Method = 'New-Object'
Measure-ScriptBlock -Method $Method -ScriptBlock {
    $list = New-Object System.Collections.Generic.List[Object]
}
#endregion

#region PS5.1 calling consructor
# Requires -Version 5.1
$Method = '5.1 - [object]::new()'
Measure-ScriptBlock -Method $Method -ScriptBlock {
    $list = [Collections.Generic.List[Object]]::new()
}
#endregion

#region casting empty array
$Method = 'casting empty array'
Measure-ScriptBlock -Method $Method -ScriptBlock {
    $list = [Collections.Generic.List[Object]]@()
}
#endregion

#region casting empty array from hashtable
$Method = 'casting empty hashtable'
Measure-ScriptBlock -Method $Method -ScriptBlock {
    $list = [Collections.Generic.List[Object]]@{}
}
#endregion


#region strong typing
$Method = 'strong typing'
Measure-ScriptBlock -Method $Method -ScriptBlock {
    [Collections.Generic.List[Object]] $list = @()
}
#endregion

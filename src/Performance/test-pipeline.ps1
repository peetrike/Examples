#Requires -Version 2

[CmdletBinding()]
param (
        [int]
    $ItemCount = 10000
)

function get-data {
    [cmdletbinding()]
    param (
        [parameter(
            ValueFromPipeline = $true
        )]
        $inputObject
    )
    begin {
        write-verbose "alustame"
    }
    process {
        Write-Verbose ('Processing {0}' -f $inputObject)
        $inputObject
    }
    end {
        Write-Verbose 'lõpetame'
    }
}

function get-data2 {
    [cmdletbinding()]
    param (
        [parameter(
            ValueFromPipeline = $true
        )]
        $inputObject
    )
    begin {
        write-verbose "alustame"
        # $Collection = @()
        $Collection = [Collections.Generic.List[Object]] @()
    }
    process {
        Write-Verbose ('Processing {0}' -f $inputObject)
        $Collection.Add($inputObject)
    }
    end {
        Write-Verbose 'lõpetame'
        $Collection.ToArray()
    }
}

'ItemCount: {0}' -f $ItemCount

"`nForeach-Object without any function"
$result = 1..$ItemCount | measure-command {
    Get-ChildItem -Recurse | ForEach-Object {
        Write-Verbose ('Processing {0}' -f $_)
        $_
    }
}
"Total ms: {0}`n" -f $result.TotalMilliseconds

"`nGet-Data with emitting all object at end"
$result = 1..$ItemCount | Measure-Command {
    Get-ChildItem -Recurse | get-data2 <#-Verbose #> #| ForEach-Object { $_.name }
}
'Total ms: {0}' -f $result.TotalMilliseconds

"`nGet-Data with emitting one object at time"
$result = 1..$ItemCount | Measure-Command {
    Get-ChildItem -Recurse | get-data <#-Verbose #> #| ForEach-Object { $_.name }
}
'Total ms: {0}' -f $result.TotalMilliseconds

"`nProcess every object in pipeline"
Get-ChildItem | get-data -Verbose

"`nCollect objects and emit in end section"
Get-ChildItem | get-data2 -Verbose

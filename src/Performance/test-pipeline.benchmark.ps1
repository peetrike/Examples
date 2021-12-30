#Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 1000
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

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'Foreach-Object'                       = {
            Get-ChildItem -Recurse | ForEach-Object {
                Write-Verbose ('Processing {0}' -f $_)
                $_
            }
        }
        'Function: emit data in end block'     = {
            Get-ChildItem -Recurse | get-data2
        }
        'Function: emit data in process block' = {
            Get-ChildItem -Recurse | get-data
        }
    } -GroupName $iterations
}

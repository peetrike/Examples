#Requires -Module BenchPress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

$testObject = [pscustomobject]@{
    One = 'One'
    two = 'two'
    number = 11
    boolean = $true
    object = [System.Object]
}

function f1 {
    [CmdletBinding()]
    param (
            [Parameter(Mandatory, ValueFromPipeline)]
            [Object]
        $InputObject,
            [string]
        $One,
            [string]
        $Two,
            [int]
        $number,
            [bool]
        $boolean,
            [object]
        $object
    )
    process {
        $OutObject = $InputObject
        $PSBoundParameters.Remove('InputObject')
        foreach ($key in $PSBoundParameters.Keys | Where-Object { 'Verbose', 'Debug' -notcontains $_ }) {
            if ($key -match '^One$') {
                $OutObject.$key = $PSBoundParameters.$key.ToUpper()
            } elseif ($key -match 'two') {
                $OutObject.$key = $PSBoundParameters.$key.ToLower()
            } else {
                $OutObject.$key = $PSBoundParameters.$key
            }
        }
        $OutObject
    }
}

function f2 {
    [CmdletBinding()]
    param (
            [Parameter(Mandatory, ValueFromPipeline)]
            [Object]
        $InputObject,
            [string]
        $One,
            [string]
        $Two,
            [int]
        $number,
            [bool]
        $boolean,
            [object]
        $object
    )

    process {
        $OutObject = $InputObject
        $PSBoundParameters.Remove('InputObject')
        switch -Wildcard ($PSBoundParameters.Keys | Where-Object { 'Verbose', 'Debug' -notcontains $_ }) {
            'One' {
                $OutObject.One = $PSBoundParameters.$_.ToUpper()
            }
            'two' {
                $OutObject.One = $PSBoundParameters.$_.ToLower()
            }
            default {
                Write-Verbose -Message ('Processing {0}' -f $_)
                $OutObject.$_ = $PSBoundParameters.$_
            }
        }
        $OutObject
    }
}


for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'Process with foreach' = {
            $testObject | f1 -one 'kaks' -Two 'YKS' -number 9
        }
        'process with switch'  = {
            $testObject | f2 -one 'kaks' -Two 'YKS' -number 9
        }
    } -GroupName $iterations
}

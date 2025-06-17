# Requires -Modules Benchpress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

function ConvertTo-UnixTime1 {
    [OutputType([double])]
    param (
            [Parameter(
                ValueFromPipeline = $true
            )]
            [datetime]
        $Date = (Get-Date)
    )

    process {
        [math]::Round(
            $Date.ToUniversalTime().Subtract([datetime]'1/1/1970').TotalSeconds
        )
    }
}

function ConvertTo-UnixTime2 {
    [OutputType([double])]
    param (
            [Parameter(
                ValueFromPipeline = $true
            )]
            [datetime]
        $Date = ([datetime]::Now)
    )

    begin {
        $UnixEpoch = [datetime] '1/1/1970'
    }

    process {
        [math]::Round(
            $Date.ToUniversalTime().Subtract($UnixEpoch).TotalSeconds
        )
    }
}

function ConvertTo-UnixTime3 {
    [OutputType([double])]
    param (
            [Parameter(
                ValueFromPipeline = $true
            )]
            [datetime]
        $Date = ([datetime]::Now)
    )

    begin {
        $UnixEpoch = [datetime]'1/1/1970'
    }

    process {
        if ($Date.Kind -ne [DateTimeKind]::Utc) {
            $Date = $Date.ToUniversalTime()
        }
        [Math]::Round(
            $Date.Subtract($UnixEpoch).TotalSeconds
        )
    }
}

$newer = $PSVersionTable.PSVersion.Major -gt 2

$dateArray = [datetime]::Now, [datetime]::UtcNow, [datetime]::Now.ToString('s'), '1970.1.1T02:00:00'

$Technique = @{
    'original' = { $dateArray | ConvertTo-UnixTime1 }
    '.net' = { $dateArray | ConvertTo-UnixTime2 }
    'conversion' = { $dateArray | ConvertTo-UnixTime3 }
}

if ($newer) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message ('PowerShell 2: {0} times' -f $Max)
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -Method $key -Iterations $max -ScriptBlock $Technique.$key
    }
}

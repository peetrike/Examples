# Requires -Modules Benchpress

[CmdletBinding()]
param (
    $Min = 10,
    $Max = 10000
)

function ConvertTo-UnixTime1 {
    [OutputType([double])]
    param (
            [Parameter(ValueFromPipeline = $true)]
            [datetime]
        $Date = [datetime]::Now
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
            [Parameter(ValueFromPipeline = $true)]
            [datetime]
        $Date = [datetime]::Now
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
            [Parameter(ValueFromPipeline = $true)]
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

function ConvertTo-UnixTimeOffset {
    [OutputType([Int64])]
    [CmdletBinding()]
    param (
            [Parameter(ValueFromPipeline = $true)]
            [DateTimeOffset]
        $Date = [DateTimeOffset]::Now
    )

    process {
        $date.ToUnixTimeSeconds()
    }
}


function ConvertTo-UnixTimeInt {
    [OutputType([Int64])]
    param (
            [Parameter(ValueFromPipeline = $true)]
            [datetime]
        $Date = [datetime]::Now
    )

    begin {
        $UnixEpoch = [datetime] '1/1/1970'
    }

    process {
        $Date.ToUniversalTime().Subtract($UnixEpoch).TotalSeconds -as [Int64]
    }
}

function ConvertTo-UnixTimeLong {
    [OutputType([long])]
    param (
            [Parameter(ValueFromPipeline = $true)]
            [datetime]
        $Date = [datetime]::Now
    )

    begin {
        $UnixEpoch = [datetime] '1/1/1970'
    }

    process {
        $Date.ToUniversalTime().Subtract($UnixEpoch).TotalSeconds -as [long]
    }
}


$dateArray = @(
    [datetime]::Now
    [datetime]::UtcNow
    [datetime]::Now.ToString('s')
    '1970.1.1T02:00:00'
    '1970.1.1T02:00:00.921'
    '1970.1.1T02:00:00.5'
    '1970.1.1'
    '1970.1.1Z'
)

$Technique = @{
    'original'   = { $dateArray | ConvertTo-UnixTime1 }
    '.net'       = { $dateArray | ConvertTo-UnixTime2 }
    'conversion' = { $dateArray | ConvertTo-UnixTime3 }
    'Int64'      = { $dateArray | ConvertTo-UnixTimeInt }
    'Long'       = { $dateArray | ConvertTo-UnixTimeLong }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
} elseif ($PSVersionTable.PSVersion.Major -ge 5) {
    $Technique += @{
        'DateTimeOffset' = { $dateArray | ConvertTo-UnixTimeOffset }
    }
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName ('{0} times' -f $iterations)
}

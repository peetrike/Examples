#Requires -Version 2.0

<#
    .SYNOPSIS
        ConvertTo-Json for PowerShell 2.0
    .DESCRIPTION
        This script contains function ConvertTo-Json20 which is written for PowerShell 2.0
    .NOTES
        Original author: Joakim Borger Svendsen - https://github.com/EliteLoser/ConvertTo-Json
    .LINK
        https://www.json.org
    .EXAMPLE
        Get-ChildItem | ConvertTo-Json20 -Depth 1

        This example converts directory listing to JSON format, expanding only 1 level of objects
#>

function EscapeJson {
    <#
        .SYNOPSIS
            Escape special characters in JSON (see json.org)
        .DESCRIPTION
            This function replaces special characters in JSON (see json.org) with escaped
            ones, such as newlines, backslashes carriage returns and tabs.
    #>
    param (
            [string]
        $String
    )
    # This is returned
    $String -replace '\\',
        '\\' -replace '\n',
        '\n' -replace '\u0008',
        '\b' -replace '\u000C',
        '\f' -replace '\r',
        '\r' -replace '\t',
        '\t' -replace '"', '\"'    # removed: -replace '/', '\/'
}

function ConvertToJsonInternal {
    param (
        $InputObject, # no type for a reason
            [int]
        $Level = 0,
            [int]
        $MaxLevel,
            [switch]
        $IsoDate,
            [switch]
        $EnumsAsStrings
    )

    $NestedParams = @{
        MaxLevel       = $MaxLevel
        IsoDate        = $IsoDate
        EnumsAsStrings = $EnumsAsStrings
    }
    $Keys = @()

    Write-Verbose -Message "Level: $Level from max $MaxLevel"
    $SpacePadding = ' ' * 4 * $Level

    try {
        $null = 1.0 + $InputObject
        if ($InputObject.GetType().Name -like 'TimeSpan') {
            $canBeNumber = $false
        } else {
            $canBeNumber = $true
        }
    } catch {
        $canBeNumber = $false
    }

    if ($null -eq $InputObject) {
        Write-Verbose -Message "Got 'null' as end value"
        $SpacePadding + 'null'
    } elseif ($InputObject -is [bool]) {
        Write-Verbose -Message 'Got boolean value'
        $SpacePadding + $InputObject.ToString().ToLower()
    } elseif ($InputObject -is [datetime] ) {
        Write-Verbose -Message 'Got a DateTime'
        $DateValue = if ($IsoDate) {
            Write-Verbose -Message 'will format it as ISO 8601.'
            $InputObject.ToString('o')
        } else {
            '\/Date({0})\/' -f [Math]::Round(
                $InputObject.ToUniversalTime().Subtract([datetime]'1970.1.1').TotalMilliSeconds
            )
        }
        '{0}"{1}"' -f $SpacePadding, $DateValue
    } elseif ($InputObject -is [enum]) {
        $result = if ($EnumsAsStrings) {
            '"{0}"' -f $InputObject
        } else {
            $InputObject.value__
        }
        $SpacePadding + $result
    } elseif ($InputObject -is [string]) {
        Write-Verbose -Message 'Got a string as end value.'
        $StringValue = '"{0}"' -f (EscapeJson -String $InputObject)
        $SpacePadding + $StringValue
    } elseif ($InputObject -as [double] -or $canBeNumber -or 0 -eq $InputObject) {
        Write-Verbose -Message 'Got a number as end value.'
        $culture = [Globalization.CultureInfo] 'en-us'
        $SpacePadding + $InputObject.ToString($culture)
    } elseif ($InputObject.GetType().Name -match '\[\]|Array') {
        Write-Verbose -Message 'Building JSON for array.'
        if ($Level -lt $MaxLevel) {
            @(
                $SpacePadding + '['
                ($InputObject | ForEach-Object {
                    Write-Debug -Message 'Getting Array member'
                        ConvertToJsonInternal @NestedParams -InputObject $_ -Level ($Level + 1) |
                            Where-Object { $_ }
                }) -join ",`n"
                $SpacePadding + ']'
            ) -join "`n"
        } else {
            $SpacePadding + ('"{0}"' -f (EscapeJson -String $InputObject))
        }
    } elseif ($InputObject -is [HashTable]) {
        Write-Verbose -Message 'Input object is a hashtable'
        $Keys = @($InputObject.Keys)
    } else {
        Write-Verbose -Message ('Input object type: {0}' -f $InputObject.GetType().FullName)
        $Keys = @(
            Get-Member -InputObject $InputObject -MemberType Properties |
                Select-Object -ExpandProperty Name
        )
    }

    if ($Keys.Count) {
        $KeyLevel = $Level + 1
        $KeyPadding = ' ' * 4 * $KeyLevel
        @(
            $SpacePadding + '{'
            @(foreach ($Key in $Keys) {
                Write-Verbose -Message ('Processing key: {0}' -f $Key)
                $keyValue = $InputObject.$Key
                $result = if ($null -eq $keyValue) {
                    Write-Verbose -Message 'Returning Null value'
                    'null'
                } elseif (
                    ($Level -ge $MaxLevel) -and -not (
                        $canBeNumber -or
                        @('string', 'boolean', 'datetime') -contains $keyValue.GetType().Name
                    )
                ) {
                    Write-Verbose -Message 'Max level reached, returning string value'
                    '"{0}"' -f (EscapeJson -String $keyValue)
                } else {
                    ConvertToJsonInternal @NestedParams -InputObject $keyValue -Level $KeyLevel
                }
                '{0}"{1}": {2}' -f $KeyPadding, $Key, $result.TrimStart()
            }) -join ",`n"
            $SpacePadding + '}'
        ) -join "`n"
    }
}

function ConvertTo-Json20 {
    <#
        .SYNOPSIS
            ConvertTo-Json for PowerShell 2.0
        .DESCRIPTION
            This script contains function ConvertTo-Json20 which is written for PowerShell 2.0
        .LINK
            https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-json
        .EXAMPLE
            Get-ChildItem | ConvertTo-Json20 -Depth 1

            This example converts directory listing to JSON format, expanding only 1 level of objects
    #>

    [OutputType([String])]
    [CmdletBinding()]
    param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [AllowNull()]
        $InputObject,
            [ValidateRange(1, 100)]
            [int]
        $Depth = 2,
            [switch]
        $Compress,
            [Alias('IsoDate')]
            [switch]
        $DateAsIso,
            [switch]
        $EnumsAsStrings
    )

    begin {
        $Collection = [Collections.Generic.List[Object]] @()
    }

    process {
        if ($null -eq $InputObject) {
            Write-Verbose -Message 'Adding $null to collection.'
        } else {
            Write-Verbose -Message ('Adding type {0} to collection.' -f $InputObject.GetType().FullName)
        }
        $Collection.Add($InputObject)
    }

    end {
        $JsonProps = @{
            MaxLevel       = $Depth
            IsoDate        = $DateAsIso
            EnumsAsStrings = $EnumsAsStrings
        }
        $JsonOutput = ConvertToJsonInternal @JsonProps -InputObject ($Collection | ForEach-Object { $_ })

        $JsonOutput = (
            $JsonOutput -split '\n' | Where-Object { $_ -match '\S' }
        ) -join "`n" -replace '^\s*|\s*,\s*$' -replace '\ *\]\ *$', ']'

        if ($Compress) {
            Write-Verbose -Message 'Compress specified.'
            $JsonOutput -replace @(
                '(?m)^\s*("(?:\\"|[^"])+"): +(.*)\s*(?<Comma>,)?\s*$'
                "`${1}:`${2}`${Comma}`n"
            ) -replace '(?m)^\s*|\s*\z|[\r\n]+'
        } else {
            $JsonOutput
        }
    }
}

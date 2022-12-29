#Requires -Version 2.0

<#
    .SYNOPSIS
        ConvertTo-Json for PowerShell 2.0
    .DESCRIPTION
        This script contains function ConvertTo-Json20 which is written for PowerShell 2.0
    .NOTES
        Original author: Joakim Borger Svendsen - https://github.com/EliteLoser/ConvertTo-Json
    .LINK
        https://www.rfc-editor.org/info/std90
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
    $String -replace '\\', '\\' -replace '"', '\"' -replace '\u0008', '\b' -replace '\u000C',
        '\f' -replace '\n', '\n' -replace '\r', '\r' -replace '\t', '\t'    # removed: -replace '/', '\/'
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
        .EXAMPLE
            Get-ChildItem | ConvertTo-Json20 -Depth 1

            This example converts directory listing to JSON format, expanding only 1 level of objects
        .EXAMPLE
            @{Account="User01";Domain="Domain01";Admin="True"} | ConvertTo-Json20 -Compress

            This command shows the effect of using the Compress parameter of ConvertTo-Json20.
            The compression affects only the appearance of the string, not its validity.
        .EXAMPLE
            ConvertTo-Json20 -InputObject (Get-Date) -DateAsIso

            This command converts date into ISO 8601 format.
        .LINK
            https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertto-json
    #>

    [OutputType([String])]
    [CmdletBinding()]
    param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [AllowNull()]
            # Specifies the objects to convert to JSON format. Enter a variable that contains the objects,
            # or type a command or expression that gets the objects.
            # You can also pipe an object to `ConvertTo-Json`.

            # The InputObject parameter is required, but its value can be null (`$null`) or an empty string.
            # When the input object is `$null`, `ConvertTo-Json` returns the JSON representation of `null`.
            # When the input object is an empty string, `ConvertTo-Json` returns the JSON representation of an
            # empty string.
        $InputObject,

            [ValidateRange(1, 100)]
            [int]
            # Specifies how many levels of contained objects are included in the JSON representation.
            # The value can be any number from `1` to `100`. The default value is `2`.
            # `ConvertTo-Json` emits a warning if the number of levels in an input object exceeds this number.
        $Depth = 2,

            [switch]
            # Omits white space and indented formatting in the output string.
        $Compress,
            [Alias('IsoDate')]
            [switch]
            # Converts DateTime object to ISO 8601 format.
        $DateAsIso,
            [switch]
            # Converts all enumerations to their string representation.
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

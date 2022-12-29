# Author: Joakim Borger Svendsen, 2017.
# JSON info: http://www.json.org
# Svendsen Tech. MIT License. Copyright Joakim Borger Svendsen / Svendsen Tech. 2016-present.
# v0.3, 2017-04-12 (second release of the day, I actually read some JSON syntax this time)
#       Fixed so you don't double-whack the allowed escapes from the diagram, not quoting null, false and true as values.
# v0.4. Scientific numbers are supported (not quoted as values). 2017-04-12.
# v0.5. Adding switch parameter EscapeAllowedEscapesToo (couldn't think of anything clearer),
#       which also double-whacks (escapes with backslash) allowed escape sequences like \r, \n, \f, \b, etc.
#       Still 2017-04-12.
# v0.6: It's after midnight, so 2017-04-13 now. Added -QuoteValueTypes that makes it quote null, true and false as values.
# v0.7: Changed parameter name from EscapeAllowedEscapesToo to EscapeAll (... seems obvious now). Best to do it before it's
#       too late. 2017-04-13.
# v0.7.1: Made the +/- after "e" in numbers optional as this is apparently valid (as plus, then)
# v0.8: Added a -Compress parameter! 2017-04-13.
# v0.8.1: Fixed bug that made "x.y" be quoted (but scientific numbers and integers worked all the while). 2017-04-14.
# v0.8.2: Fixed bug with calculated properties (yay, this improves flexibility significantly). 2017-04-14.
# v0.9: Almost too many changes to mention. Now null, true and false as _value types_ are unquoted, otherwise they
#       are quoted. Comparing to the PowerShell team's ConvertTo-Json. Now escaping works better and more
#       standards-conforming. If you have a newline in the strings, it'll be replaced by "\n" (literally, not a newline),
# while if you have "\n" literally, it'll turn into \\n. Code quality improvements. Refactoring. Still some more to fix,
# but it's getting better. Datetime stuff is bothering me, not sure I like how it's handled in the PS team's cmdlet, but I
# don't have a sufficiently informed opinion.
#
# v0.9.1: Formatting fixes.
# v0.9.2: Returning proper value types when sending in only single values of $true and $false (passed through).
#         $null is buggy, but only if you pass in _nothing_ else, but $null. As a value in an array, hash or
#         anywhere else, it works fine.
# v0.9.2.1: Forgot.
# v0.9.2.2: Adding escaping of "solidus" (forward slash).
# v0.9.3: Coerce numbers from strings only if -CoerceNumberStrings is specified (non-default), properly detect numerical types and
#         by default omit double quotes only on these.
# v0.9.3.1: Respect and do not doublewhack/escape (regex) "\u[0-9a-f]{4}".
# v0.9.3.2: Undoing previous change ... (wrong logic).
# v0.9.3.3: Comparing to the PS team's ConvertTo-Json again and they don't escape "/" alone. Undoing 0.9.2.2 change.
# v0.9.3.4: Support the IA64 platform and int64 on that too.
# v0.9.4.0: Fix nested array bracket alignment issues. 2017-10-21.
# v0.9.5.0: Handle NaN for [Double] so it's a string and doesn't break JSON syntax with "Nan" unquoted
#           in the data.
#           * Add the -DateTimeAsISO8601 switch parameter (causing datetime objects to be in this format:
#           '2018-06-25T01:25:00').
# v0.9.5.1: Handle "infinity" as well for System.Double.
# v0.9.5.2: Fix bug with DateTime ISO formatting inside hash tables and PS objects.
# v1.0: Improve readability, by "popular" demand...
######################################################################################################

# Take care of special characters in JSON (see json.org), such as newlines, backslashes
# carriage returns and tabs.
# '\\(?!["/bfnrt]|u[0-9a-f]{4})'
function EscapeJson {
    param (
            [string]
        $String
    )
    # removed: #-replace '/', '\/' `
    # This is returned
    $String -replace '\\', '\\' -replace '\n', '\n' `
        -replace '\u0008', '\b' -replace '\u000C', '\f' -replace '\r', '\r' `
        -replace '\t', '\t' -replace '"', '\"'
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
        $StringToNumber

    )

    $NestedParams = @{
        IsoDate        = $IsoDate
        StringToNumber = $StringToNumber
        MaxLevel       = $MaxLevel
    }
    $Keys = @()

    Write-Verbose -Message "Level: $Level from max $MaxLevel"
    $SpacePadding = ' ' * 4 * $Level

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
    } elseif ($InputObject -is [string]) {
        try {
            $null = 1.0 + $InputObject
            $canBeConverted = $true
        } catch {
            $canBeConverted = $false
        }
        $StringValue = if ($StringToNumber -and $canBeConverted) {
            Write-Verbose -Message 'Converting string to number'
            $InputObject
        } else {
            Write-Verbose -Message 'Got a string as end value.'
            '"{0}"' -f (EscapeJson -String $InputObject)
        }
        $SpacePadding + $StringValue
    } elseif ($InputObject -as [double]) {
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
                        ConvertToJsonInternal @NestedParams -InputObject $_ -Level ($Level+1) |
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
                    ($Level -ge $MaxLevel) -and (
                        @('string', 'boolean', 'datetime') -notcontains $keyValue.GetType().Name <# -or
                        ($InputObject.$Key | Measure-Object).Count -gt 1 #>
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

function ConvertTo-STJson {
    [CmdletBinding()]
    [OutputType([String])]
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
            [Alias('StringToNumber')]
            [switch]
        $CoerceNumberStrings,
            [Alias('IsoDate')]
            [switch]
        $DateTimeAsISO8601
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
            IsoDate        = $DateTimeAsISO8601
            StringToNumber = $CoerceNumberStrings
            MaxLevel       = $Depth
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

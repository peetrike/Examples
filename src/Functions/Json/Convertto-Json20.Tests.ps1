#Requires -Version 2
[CmdletBinding()]
param ()
<#
    Pester 4.x tests for Svendsen Tech's ConvertTo-Json20. Joakim Borger Svendsen.
    Initially created on 2017-10-21.
#>

Import-Module 'C:\Program Files\WindowsPowerShell\Modules\Pester\4.10.1\Pester.psd1' -Verbose:$false

# Standardize the decimal separator to a period (not making it dynamic for now).
#$Host.CurrentCulture.NumberFormat.NumberDecimalSeparator = "."

$MyScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Write-Verbose -Message ('Operating from: {0}' -f $MyScriptRoot)
. "$MyScriptRoot\ConvertTo-Json20.ps1"

Describe ConvertTo-Json20 {

    Context 'Simple value types' {
        It 'Null and boolean values are accounted for when passed in alone' {
            ConvertTo-Json20 -InputObject $null | Should -Be "null"
            ConvertTo-Json20 -InputObject $false | Should -Be "false"
            ConvertTo-Json20 -InputObject $true | Should -Be "true"
        }

        It 'Enum values are treated as asked' {
            ConvertTo-Json20 -InputObject $WarningPreference |
                Should -be $WarningPreference.value__
            ConvertTo-Json20 -InputObject $WarningPreference -EnumsAsStrings |
                Should -be ('"{0}"' -f $WarningPreference)
        }
        It 'A number value should not be quoted' {
            ConvertTo-Json20 -InputObject 1 -Compress | Should -Be "1"
            ConvertTo-Json20 -InputObject 1.1 -Compress | Should -Be "1.1"
            ConvertTo-Json20 -InputObject 1.12e-2 -Compress | Should -Be "0.0112"
        }

        It 'A number as a string should be quoted.' {
            ConvertTo-Json20 -InputObject "1" -Compress | Should -Be '"1"'
            ConvertTo-Json20 -InputObject "1.1" -Compress | Should -Be """1.1"""
            ConvertTo-Json20 -InputObject "1.12e-2" -Compress | Should -Be """1.12e-2"""
        }

        It 'Double quotes, newlines and carriage returns are escaped within a string' {
            ConvertTo-Json20 -InputObject "string with a`n newline a `r carriage return and a `"quoted`" word" -Compress |
                Should -Be '"string with a\n newline a \r carriage return and a \"quoted\" word"'
        }

        It "Double quotes, newlines and carriage returns are escaped within a string in a hashtable value" {
            ConvertTo-Json20 -InputObject @{ Key = "string with a`n newline a `r carriage return and a `"quoted`" word" } -Compress |
                Should -Be '{"Key":"string with a\n newline a \r carriage return and a \"quoted\" word"}'
        }

        It 'Formats datetime as ISO 8601 when you specify the switch parameter' {
            $CheckDate = [datetime]::Today
            $Object = @{ nest = @{ datetime = $CheckDate } }
            $result = ConvertTo-Json20 -InputObject $Object -Compress -DateAsIso
            Write-Verbose -Message $result
            $result | Should -Be ('{"nest":{"datetime":"' + $CheckDate.ToString('o') + '"}}')
        }
    }

    Context 'Complex value types' {
        BeforeAll {
            $TestObject = @(
                @(
                    @(1..3),
                    'a'
                    'b'
                    @{
                        key = @(
                            1
                            @(5, 6, 7),
                            'x'
                        )
                    }
                ),
                @{
                    a = @(
                        'y'
                        'z',
                        @(
                            1,
                            @(
                                'innerinner',
                                @(
                                    'innerinnerinner'
                                    $Null
                                    "foo"
                                    @{
                                        innerkey = 'g'
                                    }
                                    @{
                                        inkey = @{
                                            x = 'f'
                                        }
                                    }
                                ),
                                @(3, 4)
                            )
                        )
                    )
                }
            )
        }

        It 'Test hashtable structure with number, string, null, true and false as values' {
            ConvertTo-Json20 -InputObject @{ Key = 1.23 } -Compress | Should -Be "{`"Key`":1.23}"
            ConvertTo-Json20 -InputObject @{ Key = 'null' } -Compress | Should -Be "{`"Key`":`"null`"}"
            ConvertTo-Json20 -InputObject @{ Key = $Null } -Compress | Should -Be "{`"Key`":null}"
            ConvertTo-Json20 -InputObject @{ Key = $True } -Compress | Should -Be "{`"Key`":true}"
            ConvertTo-Json20 -InputObject @{ Key = $False } -Compress | Should -Be "{`"Key`":false}"
        }

        It 'Test custom PowerShell object with number, string, null, true and false as values' {
            ConvertTo-Json20 -InputObject (New-Object -TypeName PSObject -Property @{ Key = 1.23 }) -Compress |
                Should -Be "{`"Key`":1.23}"
            ConvertTo-Json20 -InputObject (New-Object -TypeName PSObject -Property @{ Key = 'null' }) -Compress |
                Should -Be "{`"Key`":`"null`"}"
            ConvertTo-Json20 -InputObject (New-Object -TypeName PSObject -Property @{ Key = $Null }) -Compress |
                Should -Be "{`"Key`":null}"
            ConvertTo-Json20 -InputObject (New-Object -TypeName PSObject -Property @{ Key = $True }) -Compress |
                Should -Be "{`"Key`":true}"
            ConvertTo-Json20 -InputObject (New-Object -TypeName PSObject -Property @{ Key = $False }) -Compress |
                Should -Be "{`"Key`":false}"
        }

        It 'Test single array with numbers, strings, null and boolean as values' {
            ConvertTo-Json20 -InputObject @(1, 2, 3, 'test', $null, $true, $false, 'bar') -Compress |
                Should -Be '[1,2,3,"test",null,true,false,"bar"]'
        }

        It 'Test array as hashtable value, with numbers and strings' {
            # Test a PSCustomObject at the same time. PSv2-compatible syntax/creation (not ordered).
            $Number = New-Object -TypeName PSObject -Property @{
                Key = @(1.12e-2, 2, "3", 'foo')
            }
            ConvertTo-Json20 -InputObject $Number -Compress | Should -Be "{`"Key`":[0.0112,2,`"3`",`"foo`"]}"
        }

        It 'Test complex/mixed data structure' {
            ConvertTo-Json20 -InputObject @(
                @(1..3), 'a', 'b',
                @{
                    NestedMore = @(1, @{
                        foo = @{ key = 'bar' }
                    })
                }
            ) -Compress -Depth 4 |
                Should -Be '[[1,2,3],"a","b",{"NestedMore":[1,{"foo":{"key":"bar"}}]}]'
        }

        It 'Test .NET object conversion' {
            $Object = (Get-UICulture).Calendar
            $comparisonString = (
                '{"AlgorithmType":1,"CalendarType":1,"Eras":"1","IsReadOnly":' +
                $Object.IsReadOnly.ToString().ToLower() + ',"MaxSupportedDateTime":"\/Date(253402293600000)\/",' +
                '"MinSupportedDateTime":"\/Date(-62135596800000)\/","TwoDigitYearMax":' +
                $Object.TwoDigitYearMax +'}'
            )
            ConvertTo-Json20 -InputObject $Object -Compress -Depth 1 |
                Should -Be $comparisonString
        }

        It 'Compressed output is identical to the built-in ConvertTo-Json on PowerShell 3+' {
            $Object = @{
                a = @(@(1..3), 'a', 'b', @{ key = @(1, @(5,6,7), 'x') })
                b = @{ a = @('y', 'z', @(1, @('innerinner', @('innerinnerinner', "innerinnerinner2", @{
                innerkey = 'g' }, @{ inkey = 'f'} ), @(3,4) ) ) )} }
            $NewJson = ConvertTo-Json -InputObject $Object -Compress -Depth 99
            ConvertTo-Json20 -InputObject $Object -Compress -Depth 99 |
                Should -Be $NewJson
        } -Skip:($PSVersionTable.PSVersion.Major -lt 3)

        it 'Test indentation/formatting of a complex data structure with limited depth' {
            ConvertTo-Json20 -InputObject $TestObject -Depth 3 |
            Should -Be ( @'
[
    [
        [
            1,
            2,
            3
        ],
        "a",
        "b",
        {
            "key": "1 System.Object[] x"
        }
    ],
    {
        "a": [
            "y",
            "z",
            "1 System.Object[]"
        ]
    }
]
'@ -replace '\r')
        }

        It 'Test indentation/formatting of a complex data structure with extended depth' {
            ConvertTo-Json20 -InputObject $TestObject -Depth 9 |
                Should -Be ( @'
[
    [
        [
            1,
            2,
            3
        ],
        "a",
        "b",
        {
            "key": [
                1,
                [
                    5,
                    6,
                    7
                ],
                "x"
            ]
        }
    ],
    {
        "a": [
            "y",
            "z",
            [
                1,
                [
                    "innerinner",
                    [
                        "innerinnerinner",
                        null,
                        "foo",
                        {
                            "innerkey": "g"
                        },
                        {
                            "inkey": {
                                "x": "f"
                            }
                        }
                    ],
                    [
                        3,
                        4
                    ]
                ]
            ]
        ]
    }
]
'@ -replace '\r') # \n becomes \r\n in this string, but is only \n in the JSON,
                      # so it breaks the comparison. Workaround. Can't have \r in the test data.
        }
    }

    It 'Test for PSScriptAnalyzer warnings' {
        $AnalyzerProps = @{
            Path = "$MyScriptRoot\ConvertTo-Json20.ps1"
            Severity = 'Warning'
            Settings = @{
                IncludeDefaultRules = $true
                Rules               = @{
                    PSUseCompatibleCmdlets = @{
                        Compatibility = @('desktop-2.0-windows')
                    }
                    PSUseCompatibleSyntax  = @{
                        Enable         = $true
                        TargetVersions = @(
                            '2.0'
                        )
                    }
                }
            }
        }
        Invoke-ScriptAnalyzer @AnalyzerProps | Should -BeNullOrEmpty
    } -Skip:(-not (Get-Command -Name 'Invoke-ScriptAnalyzer' -ErrorAction SilentlyContinue))
}

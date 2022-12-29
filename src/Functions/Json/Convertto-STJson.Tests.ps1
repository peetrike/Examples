#Requires -Version 2
[CmdletBinding()]
param ()
<#
    Pester 4.x tests for Svendsen Tech's ConvertTo-STJson. Joakim Borger Svendsen.
    Initially created on 2017-10-21.
#>

Import-Module 'C:\Program Files\WindowsPowerShell\Modules\Pester\4.10.1\Pester.psd1' -Verbose:$false

# Standardize the decimal separator to a period (not making it dynamic for now).
#$Host.CurrentCulture.NumberFormat.NumberDecimalSeparator = "."

$MyScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
write-verbose -Message ('Operating from: {0}' -f $MyScriptRoot)
. "$MyScriptRoot\ConvertTo-STJson.ps1"

Describe ConvertTo-STJson {

    Context 'Simple value types' {
        It 'Null and boolean values are accounted for when passed in alone' {
            ConvertTo-STJson -InputObject $null | Should -Be "null"
            ConvertTo-STJson -InputObject $false | Should -Be "false"
            ConvertTo-STJson -InputObject $true | Should -Be "true"
        }

        It 'A number value should not be quoted' {
            ConvertTo-STJson -InputObject 1 -Compress | Should -Be "1"
            ConvertTo-STJson -InputObject 1.1 -Compress | Should -Be "1.1"
            ConvertTo-STJson -InputObject 1.12e-2 -Compress | Should -Be "0.0112"
        }

        It 'A number as a string should be quoted.' {
            ConvertTo-STJson -InputObject "1" -Compress | Should -Be '"1"'
            ConvertTo-STJson -InputObject "1.1" -Compress | Should -Be """1.1"""
            ConvertTo-STJson -InputObject "1.12e-2" -Compress | Should -Be """1.12e-2"""
        }

        It 'A number as a string should not be quoted if -CoerceNumberStrings is passed' {
            ConvertTo-STJson -InputObject "1" -Compress -CoerceNumberStrings | Should -Be "1"
            ConvertTo-STJson -InputObject "1.1" -Compress -CoerceNumberStrings | Should -Be "1.1"
            ConvertTo-STJson -InputObject "1.12e-2" -Compress -CoerceNumberStrings | Should -Be "1.12e-2"

        }

        It 'Compressed output is identical to the built-in ConvertTo-Json on PowerShell 3+' {
            $Object = @{
                a = @(@(1..3), 'a', 'b', @{ key = @(1, @(5,6,7), 'x') })
                b = @{ a = @('y', 'z', @(1, @('innerinner', @('innerinnerinner', "innerinnerinner2", @{
                innerkey = 'g' }, @{ inkey = 'f'} ), @(3,4) ) ) )} }
            $NewJson = ConvertTo-Json -InputObject $Object -Compress -Depth 99
            ConvertTo-STJson -InputObject $Object -Compress -Depth 99 |
                Should -Be $NewJson
        } -Skip:($PSVersionTable.PSVersion.Major -lt 3)

        It 'Double quotes, newlines and carriage returns are escaped within a string' {
            ConvertTo-STJson -InputObject "string with a`n newline a `r carriage return and a `"quoted`" word" -Compress |
                Should -Be '"string with a\n newline a \r carriage return and a \"quoted\" word"'
        }

        It "Double quotes, newlines and carriage returns are escaped within a string in a hashtable value" {
            ConvertTo-STJson -InputObject @{ Key = "string with a`n newline a `r carriage return and a `"quoted`" word" } -Compress |
                Should -Be '{"Key":"string with a\n newline a \r carriage return and a \"quoted\" word"}'
        }

        It 'Formats datetime as ISO 8601 when you specify the switch parameter' {
            $CheckDate = [datetime]::Today
            $Object = @{ nest = @{ datetime = $CheckDate } }
            $result = ConvertTo-STJson -InputObject $Object -Compress -DateTimeAsISO8601
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
            ConvertTo-STJson -InputObject @{ Key = 1.23 } -Compress | Should -Be "{`"Key`":1.23}"
            ConvertTo-STJson -InputObject @{ Key = 'null' } -Compress | Should -Be "{`"Key`":`"null`"}"
            ConvertTo-STJson -InputObject @{ Key = $Null } -Compress | Should -Be "{`"Key`":null}"
            ConvertTo-STJson -InputObject @{ Key = $True } -Compress | Should -Be "{`"Key`":true}"
            ConvertTo-STJson -InputObject @{ Key = $False } -Compress | Should -Be "{`"Key`":false}"
        }

        It 'Test custom PowerShell object with number, string, null, true and false as values' {
            ConvertTo-STJson -InputObject (New-Object -TypeName PSObject -Property @{ Key = 1.23 }) -Compress |
                Should -Be "{`"Key`":1.23}"
            ConvertTo-STJson -InputObject (New-Object -TypeName PSObject -Property @{ Key = 'null' }) -Compress |
                Should -Be "{`"Key`":`"null`"}"
            ConvertTo-STJson -InputObject (New-Object -TypeName PSObject -Property @{ Key = $Null }) -Compress |
                Should -Be "{`"Key`":null}"
            ConvertTo-STJson -InputObject (New-Object -TypeName PSObject -Property @{ Key = $True }) -Compress |
                Should -Be "{`"Key`":true}"
            ConvertTo-STJson -InputObject (New-Object -TypeName PSObject -Property @{ Key = $False }) -Compress |
                Should -Be "{`"Key`":false}"
        }

        It 'Test single array with numbers, strings, null and boolean as values' {
            ConvertTo-STJson -InputObject @(1, 2, 3, 'test', $null, $true, $false, 'bar') -Compress |
                Should -Be '[1,2,3,"test",null,true,false,"bar"]'
        }

        It 'Test array as hashtable value, with numbers and strings' {
            # Test a PSCustomObject at the same time. PSv2-compatible syntax/creation (not ordered).
            $Number = New-Object -TypeName PSObject -Property @{
                Key = @(1.12e-2, 2, "3", 'foo')
            }
            ConvertTo-STJson -InputObject $Number -Compress | Should -Be "{`"Key`":[0.0112,2,`"3`",`"foo`"]}"
        }

        It 'Test complex/mixed data structure' {
            ConvertTo-STJson -InputObject @(
                @(1..3), 'a', 'b',
                @{
                    NestedMore = @(1, @{
                        foo = @{ key = 'bar' }
                    })
                }
            ) -Compress -Depth 4 |
                Should -Be '[[1,2,3],"a","b",{"NestedMore":[1,{"foo":{"key":"bar"}}]}]'
        }

        it 'Test indentation/formatting of a complex data structure with limited depth' {
            ConvertTo-STJson -InputObject $TestObject -Depth 3 |
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
            ConvertTo-STJson -InputObject $TestObject -Depth 9 |
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
            Path = "$MyScriptRoot\ConvertTo-STJson.ps1"
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

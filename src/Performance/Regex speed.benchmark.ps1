#Requires -Version 2
# Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 1000
)

$paths = @(
    '"C:\IT\Monitoring\zabbix\bin\win64\zabbix_agentd.exe" --config "C:\IT\Monitoring\zabbix\conf\zabbix_agentd.win.conf"',
    '"C:\Program Files\My Zabbix Agent\zabbix_agentd.exe" --multiple-agents --config "C:\Program Files\My Zabbix Agent\zabbix_agentd.conf"'
)

$PatternGeneric = '"(.+)".*--config "(.+)"'
$PatternSpecific = '"(.+\.exe)".+--config\s+"(.+\.conf)"'

$Operator = {
    foreach ($path in $paths) {
        if ($path -match $PatternGeneric) {
            $AgentPath, $ConfigPath = $Matches[1..2]
        }
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique @{
            'Regex specific'  = {
                foreach ($path in $paths) {
                    $BinaryPathName, $AgentPath, $ConfigPath = (
                        [regex] $PatternSpecific
                    ).Matches($Path).Groups.Value
                }
            }
            'assign to $null' = {
                foreach ($path in $paths) {
                    $null, $AgentPath, $ConfigPath = (
                        [regex] $PatternSpecific
                    ).Matches($Path).Groups.Value
                }
            }
            'Skip first'      = {
                foreach ($path in $paths) {
                    $AgentPath, $ConfigPath = ([regex] $PatternSpecific).Matches($Path).Groups[1..2].Value
                }
            }
            'Regex generic'   = {
                foreach ($path in $paths) {
                    $AgentPath, $ConfigPath = (
                        [regex] $PatternGeneric
                    ).Matches($Path).Groups[1..2].Value
                }
            }
            'Select-String'   = {
                $paths | Select-String -Pattern $PatternGeneric | ForEach-Object {
                    $AgentPath, $ConfigPath = $_.Matches.Groups[1..2].Value
                }
            }
            '-match'          = $Operator
        } -GroupName ('{0} times' -f $iterations)
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    @(
        Measure-ScriptBlock -Method '-match' -Iterations $Max -ScriptBlock $Operator
        Measure-ScriptBlock -Method 'Select-String' -Iterations $Max -ScriptBlock {
            $paths | Select-String -Pattern $PatternGeneric | ForEach-Object {
                $AgentPath, $ConfigPath = $_.Matches |
                    Select-Object -ExpandProperty Groups |
                    Select-Object -ExpandProperty Value -Skip 1
            }
        }
        Measure-ScriptBlock -Method 'Regex w/ select' -Iterations $Max -ScriptBlock {
            foreach ($path in $paths) {
                $AgentPath, $ConfigPath = ([regex] $PatternGeneric).Matches($Path) |
                    Select-Object -ExpandProperty Groups |
                    Select-Object -ExpandProperty Value -Skip 1
            }
        }
        Measure-ScriptBlock -Method 'Regex w/ foreach' -Iterations $Max -ScriptBlock {
            foreach ($path in $paths) {
                $AgentPath, $ConfigPath = (
                    ([regex] $PatternGeneric).Matches($Path) |
                        ForEach-Object { $_.Groups }
                )[1..2] | ForEach-Object { $_.Value }
            }
        }

    ) | Sort-Object -Property TotalMilliseconds
}

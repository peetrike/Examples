#Requires -Module BenchPress

param (
    $Min = 10,
    $Max = 1000
)

$paths = @(
    '"C:\IT\Monitoring\zabbix\bin\win64\zabbix_agentd.exe" --config "C:\IT\Monitoring\zabbix\conf\zabbix_agentd.win.conf"',
    '"C:\Program Files\ET Zabbix Agent\zabbix_agentd.exe" --multiple-agents --config "C:\Program Files\ET Zabbix Agent\zabbix_agentd.conf"'
)

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique @{
        'regex'           = {
            foreach ($path in $paths) {
                $BinaryPathName, $AgentPath, $ConfigPath = (
                    [regex] '"(.+\.exe)".+--config\s+"(.+\.conf)"'
                ).Matches($Path).Groups.Value
            }
        }
        'assign to $null' = {
            foreach ($path in $paths) {
                $null, $AgentPath, $ConfigPath = (
                    [regex] '"(.+\.exe)".+--config\s+"(.+\.conf)"'
                ).Matches($Path).Groups.Value
            }
        }
        'less specific'   = {
            foreach ($path in $paths) {
                $null, $AgentPath, $ConfigPath = (
                    [regex] '"(.+)".*--config "(.+)"'
                ).Matches($Path).Groups.Value
            }
        }
        'Select-String'   = {
            $paths | Select-String -Pattern '"(.+)".*--config "(.+)"' | ForEach-Object {
                $null, $AgentPath, $ConfigPath = $_.Matches.Groups.Value
            }
        }
        '-match'          = {
            foreach ($path in $paths) {
                if ($path -match '"(.+)".*--config "(.+)"') {
                    $AgentPath, $ConfigPath = $Matches[1..2]
                }
            }
        }
    } -GroupName ('{0} times' -f $iterations)
}

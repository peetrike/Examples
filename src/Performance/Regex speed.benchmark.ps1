#Requires -Version 2
# Requires -Modules BenchPress

param (
    $Min = 10,
    $Max = 1000
)

$paths = @(
    '"C:\IT\Monitoring\zabbix\bin\win64\zabbix_agentd.exe" --config "C:\IT\Monitoring\zabbix\conf\zabbix_agentd.win.conf"',
    '"C:\Program Files\My Zabbix Agent\zabbix_agent2.exe" --multiple-agents --config "C:\Program Files\My Zabbix Agent\zabbix_agentd.conf"'
)

$PatternGeneric = '"(.+)".*--config "(.+)"'
$PatternSpecific = '"(?<Agent>.+\.exe)".+--config\s+"(?<Config>.+\.conf)"'

$Technique = @{
    'Select P2S'      = {
        $paths | Select-String -Pattern $PatternGeneric | ForEach-Object {
            $AgentPath, $ConfigPath = $_.Matches |
                Select-Object -ExpandProperty Groups | Select-Object -ExpandProperty Value -Skip 1
        }
    }
    'Select P2F'      = {
        $paths | Select-String -Pattern $PatternGeneric | ForEach-Object {
            $AgentPath, $ConfigPath = ($_.Matches | Foreach-Object { $_.Groups })[1..2] |
                Foreach-Object { $_.Value }
        }
    }
    '-match G'        = {
        foreach ($path in $paths) {
            if ($path -match $PatternGeneric) {
                $AgentPath, $ConfigPath = $Matches[1..2]
            }
        }
    }
    '-match S'        = {
        foreach ($path in $paths) {
            if ($path -match $PatternSpecific) {
                $AgentPath = $Matches.Agent
                $ConfigPath = $Matches.Config
            }
        }
    }
    'Regex static FS' = {
        foreach ($path in $paths) {
            $AgentPath, $ConfigPath = [regex]::Matches($Path, $PatternSpecific) |
                Select-Object -ExpandProperty Groups |
                Select-Object -Skip 1 -ExpandProperty Value
        }
    }
    'Regex static FF' = {
        foreach ($path in $paths) {
            $AgentPath, $ConfigPath = (
                [regex]::Matches($Path, $PatternSpecific) | Foreach-Object { $_.Groups }
            )[1..2] | Foreach-Object { $_.Value }
        }
    }
    'Regex Object P2' = {
        foreach ($path in $paths) {
            $AgentPath, $ConfigPath = (
                ([regex] $PatternGeneric).Matches($Path) | Foreach-Object { $_.Groups }
            )[1..2] | Foreach-Object { $_.Value }
        }
    }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    $Technique += @{
        'Select-String'  = {
            $paths | Select-String -Pattern $PatternGeneric | ForEach-Object {
                $AgentPath, $ConfigPath = $_.Matches.Groups[1..2].Value
            }
        }
        'Regex static'   = {
            foreach ($path in $paths) {
                $AgentPath, $ConfigPath = [regex]::Matches($Path, $PatternGeneric).Groups[1..2].Value
            }
        }
        'Regex Object'   = {
            foreach ($path in $paths) {
                $AgentPath, $ConfigPath = ([regex] $PatternGeneric).Matches($Path).Groups[1..2].Value
            }
        }
        'assign to null' = {
            foreach ($path in $paths) {
                $null, $AgentPath, $ConfigPath = [regex]::Matches($Path, $PatternGeneric).Groups.Value
            }
        }
    }
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1
}

for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
    Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName "$iterations times"
}

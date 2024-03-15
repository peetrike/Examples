#Requires -Modules BenchPress

$licenseCsvPath = 'https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0'
$licenseCsvName = 'Product names and service plan identifiers for licensing.csv'
$licenseCsvURL = $licenseCsvPath, $licenseCsvName -join '/'

$OldProgress = $ProgressPreference

Measure-Benchmark -Technique @{
    'REST'                   = {
        $ProgressPreference = [Management.Automation.ActionPreference]::Continue
        $result2 = Invoke-RestMethod $licenseCsvURL -UseBasicParsing
    }
    'WebRequest'             = {
        $ProgressPreference = [Management.Automation.ActionPreference]::Continue
        $result1 = Invoke-WebRequest $licenseCsvURL -UseBasicParsing
    }
    'Rest no progress'       = {
        $ProgressPreference = [Management.Automation.ActionPreference]::SilentlyContinue
        $result2 = Invoke-RestMethod $licenseCsvURL -UseBasicParsing
    }
    'WebRequest no progress' = {
        $ProgressPreference = [Management.Automation.ActionPreference]::SilentlyContinue
        $result1 = Invoke-WebRequest $licenseCsvURL -UseBasicParsing
    }
    'Bits'                   = {
        $ProgressPreference = [Management.Automation.ActionPreference]::SilentlyContinue
        Start-BitsTransfer -Source $licenseCsvURL -Destination $licenseCsvName
    }
} -RepeatCount 1

$ProgressPreference = $OldProgress

$result1 = Invoke-WebRequest $licenseCsvURL -UseBasicParsing
$result2 = Invoke-RestMethod $licenseCsvURL -UseBasicParsing

Measure-Benchmark -Technique @{
    'REST'       = {
        $result2 | ConvertFrom-Csv
    }
    'WebRequest' = {
        $result1.ToString() | ConvertFrom-Csv
    }
} -RepeatCount 100

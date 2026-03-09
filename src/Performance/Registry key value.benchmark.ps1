[CmdletBinding()]
param (
        [int]
    $Min = 100,
        [int]
    $Max = 1000
)

$Technique = @{
    'Select generic'    = {
        $PropertyName = 'ProgramFilesDir'
        $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
        Get-ItemProperty -Path $KeyPath |
            Select-Object -ExpandProperty $PropertyName
    }
    'Select specific'   = {
        $PropertyName = 'ProgramFilesDir'
        $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
        Get-ItemProperty -Path $KeyPath -Name $PropertyName |
            Select-Object -ExpandProperty $PropertyName
    }
    'Property generic'  = {
        $PropertyName = 'ProgramFilesDir'
        $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
        (Get-ItemProperty -Path $KeyPath).$PropertyName
   }
    'Property specific' = {
        $PropertyName = 'ProgramFilesDir'
        $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
        (Get-ItemProperty -Path $KeyPath -Name $PropertyName).$PropertyName
   }
}

if ($PSVersionTable.PSVersion.Major -gt 2) {
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        $Technique += @{
            'PS 5 style' = {
                $PropertyName = 'ProgramFilesDir'
                $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
                Get-ItemPropertyValue -Path $KeyPath -Name $PropertyName
            }
        }
    }
    for ($iterations = $Min; $iterations -le $Max; $iterations *= 10) {
        Measure-Benchmark -RepeatCount $iterations -Technique $Technique -GroupName $iterations
    }
} else {
    Write-Verbose -Message 'PowerShell 2'
    Import-Module .\measure.psm1

    foreach ($key in $Technique.Keys) {
        Measure-ScriptBlock -method $key -Iterations $Max -ScriptBlock $Technique[$key]
    }
}

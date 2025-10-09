[CmdletBinding()]
param ()

function Write-Log {
    # .EXTERNALHELP telia.common-help.xml
    [OutputType([void])]

    [CmdletBinding()]
    param (
            [Parameter(Position = 0, ValueFromPipeline = $true)]
            [string]
        $Message,
            [Parameter(Position = 1)]
            [string]
        $Path = $(
            if ($LogFilePath) {
                $LogFilePath
            } else {
                Join-Path -Path $PWD -ChildPath 'WriteLog.txt'
            }
        ),
            [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug', 'Log', 'Empty')]
            [Alias('Type')]
            [string]
        $Level = 'Info',
            [bool]
        $WriteLog = $true,
            [switch]
        $NoDate,
            [switch]
        $AddEmptyLine
    )

    begin {
        if ($NoDate) {
            $screenPattern = '{1}'
            $msgPattern = '{0,-9} - {2}'
        } else {
            $screenPattern = '{0} - {1}'
            $msgPattern = '{0,-9} - {1} - {2}'
        }
        $ActionPreferenceList = @(
            [Management.Automation.ActionPreference]::Stop
            [Management.Automation.ActionPreference]::Continue
            [Management.Automation.ActionPreference]::Inquire
            [Management.Automation.ActionPreference]::Suspend
            [Management.Automation.ActionPreference]::Break
        )
        $LogLevel = '[{0}]' -f $Level.ToUpper()
        $SupressConfirmation = @{
            WhatIf  = $false
            Confirm = $false
        }
    }

    process {
        $TimeStamp = [datetime]::Now.ToString('G')
        $Time = [datetime]::Now.ToString('T')
        $ScreenMessage = $screenPattern -f $Time, $Message
        $LogMessage = $msgPattern -f $LogLevel, $TimeStamp, $Message

        switch ($Level) {
            'Error' {
                if ($WriteLog -and ($ErrorActionPreference -in $ActionPreferenceList)) {
                    Add-Content -Path $Path -Value $LogMessage @SupressConfirmation
                }
                Write-Error -Message $ScreenMessage
            }
            'Warning' {
                if ($WriteLog -and ($WarningPreference -in $ActionPreferenceList)) {
                    Add-Content -Path $Path -Value $LogMessage @SupressConfirmation
                }
                Write-Warning -Message $ScreenMessage
            }
            'Info' {
                $Logging = $true
                if ($InformationPreference) {
                    $Logging = $InformationPreference -in $ActionPreferenceList
                }
                if ($WriteLog -and $Logging) {
                    Add-Content -Path $Path -Value $LogMessage @SupressConfirmation
                }
                if (Get-Command Write-Information -ErrorAction SilentlyContinue) {
                    Write-Information -MessageData $ScreenMessage -InformationAction Continue -Tags 'Log'
                } else {
                    Write-Host $ScreenMessage
                }
            }
            'Verbose' {
                if ($WriteLog -and ($VerbosePreference -in $ActionPreferenceList)) {
                    Add-Content -Path $Path -Value $LogMessage @SupressConfirmation
                }
                Write-Verbose -Message $ScreenMessage
            }
            'Debug' {
                if ($WriteLog -and ($DebugPreference -in $ActionPreferenceList)) {
                    Add-Content -Path $Path -Value $LogMessage
                }
                Write-Debug -Message $ScreenMessage
            }
            'Log' {
                $prefix = '[LOG]'
                if ($WriteLog) {
                    Add-Content -Path $Path -Value $LogMessage @SupressConfirmation
                }
            }
        }
    }

    end {
        if ($AddEmptyLine -or ($Level -like 'Empty')) {
            Add-Content -Value '' -Path $Path @SupressConfirmation
        }
    }
}

$LogName = $MyInvocation.MyCommand.Name.Replace('ps1', 'log')
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath $LogName

Write-Log -Message 'Scheduled task test'

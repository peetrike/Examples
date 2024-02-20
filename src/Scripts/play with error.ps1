[CmdletBinding()]
param (
        [ValidateSet(
            'Write-Error',
            'Throw',
            'PSCmdlet'
        )]
    $Action,
        [ValidateSet(
            'Message',
            'Exception',
            'ErrorRecord',
            'PSCmdlet'
        )]
    $Details,
        [switch]
    $Terminating
)

$Error.Clear()
$Server = Resolve-DnsName www.ee
$Message = 'No server name specified.'
$RecommendedAction = 'Please set default server or specify server name.'
$CategoryActivity   = 'Get-MySession'
$CategoryTargetName = 'Server'
$CategoryTargetType = $Server.GetType()

$Exception = New-Object -TypeName 'System.Management.Automation.RuntimeException' -ArgumentList @(
    $Message
)

$ErrorId = 'MissingServer'
$errorCategory = [System.Management.Automation.ErrorCategory]::ObjectNotFound
$ErrorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
    $Exception
    $ErrorId
    $errorCategory
    $Server
)

switch ($Action) {
    'Write-Error' {
        switch ($Details) {
            'Message' {
                $ErrorProps = @{
                    Message            = $Message
                    Category           = $errorCategory
                    ErrorId            = $ErrorId
                    TargetObject       = $Server
                    RecommendedAction  = $RecommendedAction
                    #CategoryActivity   = $CategoryActivity
                    CategoryTargetName = $CategoryTargetName
                    CategoryTargetType = $CategoryTargetType
                }
                if ($Terminating.IsPresent) {
                    $ErrorProps.ErrorAction = 'Stop'
                }
                Write-Error @ErrorProps
            }
            'Exception' {
                $ErrorProps = @{
                    Exception          = $Exception
                    Category           = $errorCategory
                    ErrorId            = $ErrorId
                    TargetObject       = $Server
                    RecommendedAction  = $RecommendedAction
                    #CategoryActivity   = $CategoryActivity
                    CategoryTargetName = $CategoryTargetName
                    CategoryTargetType = $CategoryTargetType
                }
                if ($Terminating.IsPresent) {
                    $ErrorProps.ErrorAction = 'Stop'
                }
                Write-Error @ErrorProps
            }
            'ErrorRecord' {
                $ErrorProps = @{
                    ErrorRecord        = $ErrorRecord
                    RecommendedAction  = $RecommendedAction
                    #CategoryActivity   = $CategoryActivity
                    CategoryTargetName = $CategoryTargetName
                    CategoryTargetType = $CategoryTargetType
                }
                if ($Terminating.IsPresent) {
                    $ErrorProps.ErrorAction = 'Stop'
                }
                Write-Error @ErrorProps
            }
            'PSCmdlet' {
                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    }
    'Throw' {
        throw $ErrorRecord
    }
    'PSCmdlet' {
        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
    }
}

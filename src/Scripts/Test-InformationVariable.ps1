[CmdletBinding()]
param (
        [ValidateSet(
            'Module',
            'Script'
        )]
        [string]
    $Target
)

switch ($Target) {
    'Module' {
        New-Module -Name TestInformationVariable -ScriptBlock {
            function Test-Public {
                [CmdletBinding()]
                param ()

                private

                'Working in public function'
                $InformationObject = @{
                    InvocationInfo        = $PSCmdlet.MyInvocation
                    InformationPreference = $InformationPreference
                }
                if ($PSBoundParameters.ContainsKey('InformationVariable')) {
                    $InformationObject.InformationVariable = $PSBoundParameters['InformationVariable']
                }
                $result = [PSCustomObject] $InformationObject
                Write-Information -MessageData $result -Tags Object
            }
            function private {
                [CmdletBinding()]
                param ()

                Write-Host 'Working in private function'
                $InformationObject = @{
                    InvocationInfo        = $PSCmdlet.MyInvocation
                    InformationPreference = $InformationPreference
                }
                if ($PSBoundParameters.ContainsKey('InformationVariable')) {
                    $InformationObject.InformationVariable = $PSBoundParameters['InformationVariable']
                }
                $result = [PSCustomObject] $InformationObject
                Write-Information -MessageData $result -Tags Object
            }
            Export-ModuleMember -Function Test-public
        } | Import-Module

        Test-Public -informationVariable Info
        $info | Where-Object Tags -like 'Object' | fl * -Force
        #$info[-1].MessageData
        $info[-1].MessageData.InvocationInfo

        if ($DebugPreference) { Wait-Debugger }

        Remove-Module -Name TestInformationVariable
    }
    'Script' {
        function Test-Public {
            [CmdletBinding()]
            param ()

            private

            'Working in public function'
            $InformationObject = @{
                InvocationInfo        = $PSCmdlet.MyInvocation
                InformationPreference = $InformationPreference
            }
            if ($PSBoundParameters.ContainsKey('InformationVariable')) {
                $Informationvariable
                $InformationObject.InformationVariable = $PSBoundParameters['InformationVariable']
            }
            $result = [PSCustomObject] $InformationObject
            Write-Information -MessageData $result -Tags Object
        }

        function private {
            [CmdletBinding()]
            param ()

            Write-Host 'Working in private function'
            $InformationObject = @{
                InvocationInfo        = $PSCmdlet.MyInvocation
                InformationPreference = $InformationPreference
            }
            if ($PSBoundParameters.ContainsKey('InformationVariable')) {
                $Informationvariable
                $InformationObject.InformationVariable = $PSBoundParameters['InformationVariable']
            }
            $result = [PSCustomObject] $InformationObject
            Write-Information -MessageData $result -Tags Object
        }

        Test-Public -informationVariable Info2
        $info2 | Where-Object Tags -like 'Object' | fl * -Force
        #$info2[-1].MessageData
        $info2[-1].MessageData.InvocationInfo
    }
}

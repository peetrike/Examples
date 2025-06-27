New-Module -Name TestInformationVariable -ScriptBlock {
    function Test-Public {
        [CmdletBinding()]
        param ()

        private

        'Working in public function'
        Write-Warning -Message 'the public warning'
    }
    function private {
        [CmdletBinding()]
        param ()

        'Working in private function'
        Write-Warning -Message 'the private warning'
    }
    Export-ModuleMember -Function Test-public
} | Import-Module

Test-Public -WarningVariable warning
$warning | fl * -Force

Remove-Module -Name TestInformationVariable


function Test-Public {
    [CmdletBinding()]
    param ()

    private

    'Working in public function'
    Write-Warning -Message 'the public warning'
}

function private {
    [CmdletBinding()]
    param ()

    'Working in private function'
    Write-Warning -Message 'the private warning'
}

Test-Public -WarningVariable warning2
$warning2 | fl * -Force

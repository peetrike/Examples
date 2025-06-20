<#
    .LINK
        https://github.com/VernAnderson/PowerShell/blob/master/Animate-LittleGreenMan.ps1
#>


param (
        [int]
    $Steps,
        [int]
    $Interval
)

function Animate-LittleGreenMan {
    param (
            [ValidateRange(1, 300)]
            [ValidateScript({
                if ($_ -gt ($host.UI.RawUI.WindowSize.Width - 2)) {
                    $Exception = New-Object System.ArgumentOutOfRangeException -ArgumentList @(
                        'Steps'
                        "Little green man can't step out of screen"
                    )
                    throw $Exception
                } else { $true }
            })]
            [int]
        $Steps = 31,
            [int]
        $Interval = 125
    )

    $Head = 'O'

    foreach ($Step in 2..($Steps + 2)) {
        Clear-Host
        if ($Step % 2) {
            $Arms = '↙|↘'
            $Legs = '/ \'
            $BodyPad = $Step + 1
        } else {
            $Arms = '↓'
            $Legs = '‖'
            $BodyPad = $Step
        }

        Write-Host -Object $Head.PadLeft($Step) -ForegroundColor Green
        Write-Host -Object $Arms.PadLeft($BodyPad) -ForegroundColor Green
        Write-Host -Object $Legs.PadLeft($BodyPad) -ForegroundColor Green

        Start-Sleep -Milliseconds $Interval
    }
}

Animate-LittleGreenMan @PSBoundParameters

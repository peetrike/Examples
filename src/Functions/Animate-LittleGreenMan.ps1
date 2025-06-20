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
            [int]
        $Steps = 31,
            [int]
        $Interval = 125
    )

    $Head = 'O'

    foreach ($Step in 0..$Steps) {
        Clear-Host
        if ($Step % 2 -eq 0) {
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

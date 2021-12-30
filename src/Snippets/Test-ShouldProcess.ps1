#Requires -Version 3.0

[CmdletBinding(
    SupportsShouldProcess=$true
#    , ConfirmImpact="Medium"
)]

param(
        [Switch]
    $Force
)

$RejectAll = $false;
$ConfirmAll = $false;

foreach ($File in Get-ChildItem -File) {
    $fileName = $File.Name
    if ($PSCmdlet.ShouldProcess(
        "Removing the file '$fileName'",
        "Remove the file '$fileName'?",
        'Removing Files'
    )) {
        if ($Force -Or $PSCmdlet.ShouldContinue(
            "Are you REALLY sure you want to remove '$fileName'?",
            "Removing '$fileName'",
            [ref]$ConfirmAll,
            [ref]$RejectAll
        )) {
            "Removing $File"
        }
    }
}

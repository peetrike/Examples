$message = 'Should we do something?'
$title = 'A message'

$WshShell = New-Object -ComObject WScript.Shell

# https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/x83z1d9f(v=vs.84)
$null = $WshShell.Popup($message)

$ButtonOption = 4 +     # Show Yes and No buttons
    32 +                # Show "Question Mark" icon.
    256                 # The second button is the default button.

$result = $WshShell.Popup(
    $message,
    5,              # seconds to wait
    $title,
    $ButtonOption
)

$result

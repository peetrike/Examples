#Requires -Version 3.0

    # choose one
Get-ADGroup -Filter * |
    Out-GridView -OutputMode Single -Title 'Choose a group to see members' |
    Get-ADGroupMember

    # choose many
1..5 | ForEach-Object { notepad.exe }
Get-Process notepad |
    Out-GridView -PassThru -Title 'Pick processes to stop' |
    Stop-Process

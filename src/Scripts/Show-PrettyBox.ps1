Function Show-PrettyBox {
    <#
        .SYNOPSIS
        This function produces a display box for the user to respond to.

        .DESCRIPTION
        This function uses windows forms to produce a display box for the user to respond to.
        It allows you to specify a title, title color, message, buttons, and button color.
        It returns the text value of the button clicked.

        .PARAMETER Message
            The message to be displayed in the display box.

        .PARAMETER Title
            The Title of the display box.

        .PARAMETER TitleColor
            The color for the background of the title.

        .PARAMETER Buttons
            The text for the buttons to present to the user as choices.
            This text will be what is returned from the function when the button is clicked.

        .EXAMPLE
        Show-PrettyBox -Title "Windows 10 Upgrade" -Message "You are already upgraded." -TitleColor "Green"
        OK
        # Displays a title in green with a Gray OK button.

        .EXAMPLE
        Show-PrettyBox -Title "Windows 10 Upgrade" -Message "Continue with upgrade?" -TitleColor "Blue" -Buttons "OK","CANCEL"
        CANCEL
        # Displays a title in blue with Gray OK and CANCEL buttons.

        .EXAMPLE
        Show-PrettyBox -Title "Windows 10 Upgrade" -Message "ERROR: Your system is not ready for upgrade!" -TitleColor "Red"
        OK
        # Displays a title in red with Gray OK button.

        .EXAMPLE
        $Selection = Show-PrettyBox -Title "Windows 10 Upgrade" -Message "Would you like to upgrade?" -TitleColor "Red" -Buttons "YES","NO"
        $Selection
        NO
        # Displays a title in red with Gray YES and NO buttons and store the result in $Selection.
    #>
    Param (
        [string]$Title = "Top Title",
        [string]$Message = "Test Message",
        [string]$TitleColor = "Blue",
        [string]$ButtonColor = "Gray",
        [array]$Buttons = "OK"
    )

    # [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    Add-Type -AssemblyName System.Drawing
    # [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    Add-Type -AssemblyName System.Windows.Forms
    [void] [System.Windows.Forms.Application]::EnableVisualStyles()

    # Hard Code Form size
    $FixedWidth = 400

    # Form
    $Form = New-Object system.Windows.Forms.Form
    $Form.Size = New-Object System.Drawing.Size(400,200)
    #You can use the below method as well
    $Form.Width = 400
    $Form.Height = 250
    $form.MaximizeBox = $false
    $Form.StartPosition = "CenterScreen"
    $Form.FormBorderStyle = 'Fixed3D'
    $Form.Text = $null
    $Form.MinimizeBox = $False
    $Form.MaximizeBox = $False
    $Form.ControlBox = $False
    $Form.BackColor = "White"

    # Label
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Title
    $Label.Size = New-Object System.Drawing.Size($FixedWidth,80)
    $Label.TextAlign = "MiddleCenter"
    $Label.Location = New-Object System.Drawing.Size(0,0)
    $Label.BackColor = $TitleColor
    $Label.ForeColor = "White"
    $Font = New-Object System.Drawing.Font("Arial",15,[System.Drawing.FontStyle]::Bold)
    $form.Font = $Font
    $Form.Controls.Add($Label)

    # Label2
    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.Text = $Message
    $Label2.Size = New-Object System.Drawing.Size($FixedWidth,80)
    $Label2.TextAlign = "MiddleCenter"
    $Label2.Location = New-Object System.Drawing.Size(0,90)
    $Label2.BackColor = "White"
    $Label2.ForeColor = "Black"
    $Form.Controls.Add($Label2)

    # Set Button Start Variables
    $StartLocation = 200
    $ButtonCount = 1
    [object[]]$objButtons = New-Object System.Windows.Forms.Button

    # Build Buttons
    $Buttons | ForEach-Object {
    # Add Button
        $objButtons += New-Object System.Windows.Forms.Button
        $objButtons[$ButtonCount].Location = New-Object System.Drawing.Size(0,$StartLocation)
        $objButtons[$ButtonCount].Size = New-Object System.Drawing.Size($FixedWidth,30)
        $objButtons[$ButtonCount].Text = $_
        $objButtons[$ButtonCount].BackColor = $ButtonColor
        $objButtons[$ButtonCount].Add_Click({$Form.Close()})
        $Form.Controls.Add($objButtons[$ButtonCount])
        # Increment Variables Between Buttons
        $ButtonCount++
        $StartLocation = $StartLocation + 30
    }

    # Adjust Form Height for Buttons Added
    $Form.Height = 250 + $StartLocation - 200
    [void] $Form.ShowDialog()
    Return $Form.activeControl.Text
}

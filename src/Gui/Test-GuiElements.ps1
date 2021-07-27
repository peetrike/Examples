﻿$message = 'Should we do something?'
$title = 'A message'

#region Read-Host

$result = Read-Host -Prompt $message
$Password = Read-Host -Prompt 'Please enter the password' -AsSecureString

#endregion

#region Get-Credential as GUI element

#Requires -Version 3
$CredentialProps = @{
    UserName = 'Give me some information'
}

switch ($PSVersionTable.PSVersion.Major) {
    { $_ -ge 6 } {
        $CredentialProps.Title = $title
    }
    Default {
        $CredentialProps.Message = $message
    }
}

$result = Get-Credential @CredentialProps
$result.UserName
$result.GetNetworkCredential().Password

#endregion

#region Powershell Prompt for Choices

# https://docs.microsoft.com/dotnet/api/System.Management.Automation.Host.ChoiceDescription
$yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Yes, do it'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, leave it as it is.'
$cancel = [Management.Automation.Host.ChoiceDescription]'&Cancel'

$options = ($yes, $no, $cancel)

# https://docs.microsoft.com/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice
$result = $host.ui.PromptForChoice(
    $title,
    $message,
    $options,
    2           # default choice
)

switch ($result) {
    0 { 'You selected Yes.' }
    1 { 'You selected No.' }
    2 { 'You selected Cancel.' }
}

#endregion

#Requires -Version 2
# Requires -Assembly "System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
# Requires -Assembly "Microsoft.VisualBasic, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

<#
    .SYNOPSIS
        Demonstrates how to automate keyboard-based user interface.
    .DESCRIPTION
        This example shows how script can emulate keyboard input and automate
        several activities that are normally done interactively
    .LINK
        Windows Scripting Host: https://docs.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/8c6yea83(v=vs.84)
    .LINK
        .NET Framework: https://docs.microsoft.com/dotnet/api/system.windows.forms.sendkeys
    .LINK
        VB.Net Window activation: https://docs.microsoft.com/dotnet/api/microsoft.visualbasic.interaction.appactivate
    .LINK
        WScript.Shell window activation: https://docs.microsoft.com/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/wzcddbek(v=vs.84)
    .LINK
        Scriptable Shell object: https://docs.microsoft.com/windows/win32/shell/shell
#>

[CmdletBinding()]
param (
        [Globalization.CultureInfo]
    $Language = $PSCulture
)

#region Variables
$NotePadName = 'Notepad'
switch ($Language.Name) {
    'et-EE' {
        $ExcelName = 'Vihik1 - Excel'
        $UacName = 'Kasutajakonto kontroll'
        $move = 't'
    }
    default {
        $ExcelName = 'Sheet1 - Excel'
        $UacName = 'User Account Control'
        $move = 'm'
    }
}
$EnterTime = 300
$EnoughTime = 500
$LongTime = 1000
#endregion

#region load necessary libraries
$WsShell = New-Object -ComObject 'WScript.Shell'
$ObjShell = New-Object -ComObject 'Shell.Application'
$Excel = New-Object -ComObject 'Excel.Application'
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
#endregion

#region Pause function
function pause {
    param (
        [string]
        $Message
    )
    Write-Host $Message
    $null = Read-Host -Prompt 'Press ENTER to continue'
}
#endregion

Start-Process $NotePadName
Start-Sleep -Milliseconds $EnoughTime

#region sample with WScript.Shell
$null = $WsShell.AppActivate($NotePadName)
Start-Sleep -Milliseconds $EnterTime
$WsShell.SendKeys('Tere, täna vaatame, kuidas arvuti ise töötab.~')
Start-Sleep -Milliseconds $EnoughTime
$WsShell.SendKeys('kõigepealt käivitame kalkulaatori.~')
#Start-Sleep -Milliseconds $EnterTime

$Excel.Visible = $true
$null = $WsShell.AppActivate($ExcelName)
$Book = $Excel.Workbooks.Add()
$Sheet = $book.ActiveSheet
Start-Sleep -Milliseconds $EnoughTime
#endregion


#region sample with .NET
pause -Message 'App Automation'

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 200
[Windows.Forms.SendKeys]::Sendwait('Ja nüüd arvutame.~~')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('1{+}2=')
Start-Sleep -Milliseconds $EnoughTime

[Microsoft.VisualBasic.Interaction]::AppActivate($ExcelName)
Start-Sleep -Milliseconds $EnterTime
$Sheet.Cells.Item(1, 1) = 1
Start-Sleep -Milliseconds $EnterTime
$Sheet.Cells[1, 2] = 2
Start-Sleep -Milliseconds $EnterTime
$Sheet.Cells.Item(1, 3).Formula = '=A1+B1'
$null = $Sheet.Range('C1').Copy()
#$Sheet.Cells.Item(1, 3).Value2 | Set-Clipboard

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 200
[Windows.Forms.SendKeys]::Sendwait('^V~')
Start-Sleep -Milliseconds $LongTime
$Excel.DisplayAlerts = $false
$Excel.Quit()
#endregion


#region UI Automation
pause 'UI Automation'

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
[Windows.Forms.SendKeys]::Sendwait('~Ja nüüd püüame liigutada Notepadi akent.~~')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('% ')
#Start-Sleep -Milliseconds 100
[Windows.Forms.SendKeys]::Sendwait($move)
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('{left}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{up}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{right}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
#Start-Sleep -Milliseconds 100
[Windows.Forms.SendKeys]::Sendwait('~')
Start-Sleep -Milliseconds $LongTime
#endregion


#region Shell Automation
pause 'Shell Automation'

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 200
[Windows.Forms.SendKeys]::Sendwait('~Minimeerime kõik aknad~')
Start-Sleep -Milliseconds $EnoughTime
$ObjShell.MinimizeAll()
Start-Sleep -Milliseconds ($LongTime * 2)
$ObjShell.UndoMinimizeALL()
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('~vaatame kõiki töötavaid rakendusi~')
Start-Sleep -Milliseconds $EnterTime
$ObjShell.WindowSwitcher()
Start-Sleep -Milliseconds ($LongTime * 2)
[Windows.Forms.SendKeys]::Sendwait('{ESC}')
Start-Sleep -Milliseconds $EnoughTime
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('~jalutame mööda Start menüüd~')
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('^{ESC}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnterTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{tab}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds $EnoughTime
[Windows.Forms.SendKeys]::Sendwait('{ESC}')
Start-Sleep -Milliseconds $LongTime
#endregion


#region web browsing
pause 'Web Browsing'
$WebSite = 'https://telia.ee'
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
[Windows.Forms.SendKeys]::Sendwait('~Lehitseme natuke veebi...~Internet Explorer~')
$ie = New-Object -ComObject 'InternetExplorer.Application'
$ie.navigate2($WebSite)
$ie.visible = $true
$IeProccessId = (get-process iexplore)[-1].Id
Start-Sleep -Milliseconds $LongTime
[Microsoft.VisualBasic.Interaction]::AppActivate($IeProccessId)
Start-Sleep -Milliseconds ($LongTime * 3)
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 100
[Windows.Forms.SendKeys]::Sendwait('Vaikimisi lehitseja.~~')
Start-Process $WebSite
Start-Sleep -Milliseconds ($LongTime * 3)
#endregion


#region Run As Admin
pause 'RunAs'

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
[Windows.Forms.SendKeys]::Sendwait('~Nüüd aga püüame käivitada midagi admin õigustes.~')
Start-Sleep -Milliseconds $LongTime
Start-Process -Verb runas powershell.exe
Start-Sleep -Milliseconds $EnoughTime
[Microsoft.VisualBasic.Interaction]::AppActivate($UacName)
[Windows.Forms.SendKeys]::Sendwait('{left}~')
#endregion

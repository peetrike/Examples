# SendKeys demo
#
# Windows Scripting Host: https://docs.microsoft.com/en-us/previous-versions/8c6yea83(v=vs.85)
# .NET Framework: https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys
# VB.Net Window activation: https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualbasic.interaction.appactivate
# Wscript.Shell window activation: https://docs.microsoft.com/en-us/previous-versions/wzcddbek(v=vs.85)


#region App name strings
$NotePadName = 'Notepad'
$CalcName = 'Kalkulaator'
$UacName = 'Kasutajakonto kontroll'
#endregion

#region load nessessary libraries
$WsShell = New-Object -ComObject 'Wscript.Shell'
$ObjShell = New-Object -ComObject 'Shell.Application'
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
#endregion

Start-Process $NotePadName
Start-Sleep -Milliseconds 500

#region sample with WScript.Shell
$null = $WsShell.AppActivate($NotePadName)
Start-Sleep -Milliseconds 300
$WsShell.SendKeys('Tere, täna vaatame, kuidas arvuti ise töötab.~')
Start-Sleep -Milliseconds 500
$WsShell.SendKeys('kõigepealt käivitame kalkulaatori.~')
Start-Sleep -Milliseconds 200
#endregion

Start-Process 'calc'
Start-Sleep -Milliseconds 1000

#region sample with .NET
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::Sendwait('Ja nüüd arvutame.~~')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::Sendwait('1{+}2=')
Start-Sleep -Milliseconds 300

[Microsoft.VisualBasic.Interaction]::AppActivate($CalcName)
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::Sendwait('1')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{+}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('2')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('~')
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::Sendwait('^C')
Start-Sleep -Milliseconds 300

[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 200
$WsShell.SendKeys('^V~')
Start-Sleep -Milliseconds 1000
#endregion

#region UI Automation
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('~Ja nüüd püüame liigutada Notepadi akent.~~')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::Sendwait('% ')
#Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('t')
Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('{left}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{up}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{right}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
#Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('~')
Start-Sleep -Milliseconds 1000
#endregion

#region Shell Automation
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::Sendwait('~Minimeerime kõik aknad~')
Start-Sleep -Milliseconds 300
$ObjShell.MinimizeAll()
Start-Sleep -Milliseconds 2000
$ObjShell.UndoMinimizeALL()
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::Sendwait('~vaatame kõiki töötavaid rakendusi~')
Start-Sleep -Milliseconds 300
$ObjShell.WindowSwitcher()
Start-Sleep -Milliseconds 2000
[System.Windows.Forms.SendKeys]::Sendwait('{ESC}')
Start-Sleep -Milliseconds 500
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('~jalutame mööda Start menüüd~')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('^{ESC}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::Sendwait('{tab}')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::Sendwait('{down}')
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::Sendwait('{ESC}')
Start-Sleep -Milliseconds 300
#endregion

#region web browsing
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('~Lehitseme natuke veebi...~Internet Explorer~')
#Start-Sleep -Milliseconds 100
$ie = New-Object -ComObject 'InternetExplorer.Application'
$ie.navigate2('https://koolitus.ee')
$ie.visible = $true
$IeProccessId = (get-process iexplore)[0].Id
Start-Sleep -Milliseconds 1000
[Microsoft.VisualBasic.Interaction]::AppActivate($IeProccessId)
Start-Sleep -Milliseconds 3000
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('Vaikimisi lehitseja.~~')
Start-Process 'https://koolitus.ee'
Start-Sleep -Milliseconds 3000
#endregion

#region Run As Admin
[Microsoft.VisualBasic.Interaction]::AppActivate($NotePadName)
#Start-Sleep -Milliseconds 100
[System.Windows.Forms.SendKeys]::Sendwait('~Nüüd aga püüame käivitada midagi admin õigustes.~')
Start-Sleep -Milliseconds 1000
Start-Process -Verb runas powershell.exe
Start-Sleep -Milliseconds 200
$null = $WsShell.AppActivate($UacName)
$WsShell.SendKeys('{left}~')
#endregion

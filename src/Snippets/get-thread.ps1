#Requires -Version 3
#Requires -Modules CimCmdlets

[CmdletBinding()]
param ()

<# Get-CimInstance -ClassName Win32_Thread |
    Where-Object { -not (get-process -id $_.processhandle)}
 #>

$ProcessList = Get-Process
foreach ($thread in Get-CimInstance -ClassName Win32_Thread -Verbose:$false) {
    $process = $ProcessList | Where-Object Id -eq $thread.ProcessHandle
    if ($process) {
        Write-Verbose -Message ("on lõim: {0}, protsess {1}" -f $thread.Handle, $process.Name)
    } else {
        $thread
    }
}

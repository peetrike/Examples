# Create the task
$action = New-ScheduledTaskAction -Execute cmd.exe -Argument '/c whoami > C:\temp\out.txt'
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount
$task = Register-ScheduledTask -TaskName MyTask -Action $action -Principal $principal

# Get the task SecurityDescriptor
$scheduler = New-Object -ComObject Schedule.Service
$scheduler.Connect()
$comTask = $scheduler.GetFolder($task.TaskPath).GetTask($task.TaskName)
$taskSDDL = $comTask.GetSecurityDescriptor(0xF)
$taskSD = [System.Security.AccessControl.RawSecurityDescriptor]::new($taskSDDL)

# Add rule for Users to read and execute the task
$usersGroup = [System.Security.Principal.NTAccount]::new('Users')
$readAndExecuteAce = [System.Security.AccessControl.CommonAce]::new(
    'None',
    'AccessAllowed',
    0xA0000000,  # GENERIC_READ, GENERIC_EXECUTE
    $usersGroup.Translate([System.Security.Principal.SecurityIdentifier]),
    $false,
    $null)
$taskSD.DiscretionaryAcl.InsertAce($taskSD.DiscretionaryAcl.Count, $readAndExecuteAce)
$newSDDL = $taskSD.GetSddlForm('All')

# Set the new SecurityDescriptor on the task
$comTask.SetSecurityDescriptor($newSDDL, 0)

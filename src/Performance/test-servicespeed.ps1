
1..10 | Measure-Command {
    Get-WmiObject -Class Win32_Service
}

1..10 | Measure-Command {
    Get-CimInstance -Class Win32_Service
}

1..10 | Measure-Command {
    Get-Service
}


# with where-object

1..10 | Measure-Command {
    Get-Service |
        Where-Object { $_.DisplayName -like "Zabbix Agent*" }
}

1..10 | Measure-Command {
    Get-WmiObject -Class Win32_Service |
        Where-Object { $_.DisplayName -like "Zabbix Agent*" }
}

1..10 | Measure-Command {
    Get-WmiObject -Class Win32_Service -Filter "Displayname LIKE 'Zabbix Agent%'" -Property Name, PathName
}

1..10 | Measure-Command {
    Get-CimInstance -Class Win32_Service -Filter "Displayname LIKE 'Zabbix Agent%'" -Property Name, PathName
}

1..10 | Measure-Command {
    Get-CimInstance -Class Win32_Service -Filter "Displayname LIKE 'Zabbix Agent%'"
}

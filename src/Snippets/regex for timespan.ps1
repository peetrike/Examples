$data = '1 hours 2 min 3 sec'
$pattern = '((?<days>\d+) days? ?)?((?<hours>\d+) hours? ?)?((?<minutes>\d+) min ?)?((?<seconds>\d+) sec)?'

if ($data -match $pattern) {
    $days = $hours = $minutes = $seconds = 0
    if ($Matches.days) {
        $days = $Matches.days
    }
    if ($Matches.hours) {
        $hours = $Matches.hours
    }
    if ($Matches.minutes) {
        $minutes = $Matches.minutes
    }
    if ($Matches.seconds) {
        $seconds = $Matches.seconds
    }
    [timespan] ('{0}.{1}:{2}:{3}' -f $days, $hours, $minutes, $seconds)
}

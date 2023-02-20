#Requires -Version 5.0

[OutputType([DateTimeOffset])]
[CmdletBinding()]
param(
    [ArgumentCompleter({
        param ($commandName, $parameterName, $wordToComplete)

        foreach ($dt in [TimeZoneInfo]::GetSystemTimeZones()) {
            if ($dt.id, $dt.displayname -match $wordToComplete) {
                [Management.Automation.CompletionResult]::new(
                    ("'{0}'" -f $dt.id),
                    $dt.DisplayName,
                    'ParameterValue',
                    ('{0}/{1} (DST:{2})' -f @(
                        $dt.StandardName
                        $dt.DaylightName
                        $dt.SupportsDaylightSavingTime
                    ))
                )
            }
        }
    })]
    [Alias('tz')]
    [string]
$TimeZone = [TimeZoneInfo]::Local.Id,
    [DateTimeOffset]
$Time = [datetime]::Now
)
function Get-DtoAt {
    [OutputType([DateTimeOffset])]
    param(
            [ArgumentCompleter({
                param ($commandName, $parameterName, $wordToComplete)

                foreach ($dt in [TimeZoneInfo]::GetSystemTimeZones()) {
                    if ($dt.id, $dt.displayname -match $wordToComplete) {
                        [Management.Automation.CompletionResult]::new(
                            ("'{0}'" -f $dt.id),
                            $dt.DisplayName,
                            'ParameterValue',
                            ('{0}/{1} (DST:{2})' -f @(
                                $dt.StandardName
                                $dt.DaylightName
                                $dt.SupportsDaylightSavingTime
                            ))
                        )
                    }
                }
            })]
            [Alias('tz')]
            [string]
        $TimeZone = [TimeZoneInfo]::Local.Id,
            [DateTimeOffset]
        $Time = [datetime]::Now
    )

    $time.ToOffset(
        [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone).GetUtcOffset($time.UtcDateTime)
    )
}

Get-DtoAt @PSBoundParameters

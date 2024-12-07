[CmdletBinding()]
param (
        [SupportsWildcards()]
        [string]
    $RightName = 'SeDenyInteractiveLogonRight',
        [switch]
    $AccountOnly
)

$searcher = [wmisearcher] @{
    Query = "select * from RSOP_UserPrivilegeRight where UserRight LIKE '$RightName'"
    Scope = 'ROOT\rsop\computer'
}

$result = $searcher.Get()

if ($AccountOnly) {
    $result.AccountList
} else {
    $result
}

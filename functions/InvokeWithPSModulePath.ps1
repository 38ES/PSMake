function InvokeWithPSModulePath {
    [CmdletBinding()]
    param(
        [string]$NewPSModulePath,
        [ScriptBlock]$ScriptBlock
    )

    $cache = $env:PSModulePath
    $env:PSModulePath = $NewPSModulePath
    try {
        & $ScriptBlock
    }
    finally {
        $env:PSModulePath = $cache
    }

}
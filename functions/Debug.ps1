function Debug {
    Param(
        [scriptblock]$ScriptBlock,
        [string]$BuildTarget = $settings.BuildTarget
    )

    if($BuildTarget -eq "Debug") {
        & $ScriptBlock
    }
}
function Release {
    Param(
        [scriptblock]$ScriptBlock,
        [string]$BuildTarget = $settings.BuildTarget
    )

    if($BuildTarget -eq "Release") {
        & $ScriptBlock
    }
}
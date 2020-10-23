function UsingModule {
    param(
        [scriptblock]$Scriptblock,
        [string]$OutputDirectory = $settings.OutputDirectory,
        [string]$Filename = $settings.ModuleName + ".psm1"
    )

    $content = & $Scriptblock | ForEach-Object {
        $current = $_
        if($current -is [string]) { $current }
        else { throw "Invalid object - expected string of module to use - $_ of type '$($_.GetType())" }
    } | ForEach-Object {
        "using module `"$_`"`r`n"
    }
        
    

    if(-not (Test-Path $OutputDirectory -PathType Container)) { New-Item $OutputDirectory -ItemType Directory | Out-Null }
    if(-not (Test-Path $settings.OutputModulePath -PathType Container)) { New-Item $settings.OutputModulePath -ItemType Directory | Out-Null }
    $content + (Get-Content (Join-Path $settings.OutputModulePath $Filename) -ErrorAction SilentlyContinue) | Out-File (Join-Path $settings.OutputModulePath $Filename)
}

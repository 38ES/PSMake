function Collate {
    param(
        [scriptblock]$Scriptblock,
        [string]$OutputDirectory = $settings.OutputDirectory,
        [string]$Filename = $settings.ModuleName + ".psm1"
    )

    $content = & $Scriptblock | % {
        $current = $_
        if($current -is [string]) { Get-ChildItem $current }
        elseif($current -is [System.IO.FileInfo]) { $current }
        else { throw "Invalid object to collate - $_ of type '$($_.GetType())" }
    } | % {

        $_ | Get-Content -raw
    }

    if(-not (Test-Path $OutputDirectory -PathType Container)) { New-Item $OutputDirectory -ItemType Directory | Out-Null }
    if(-not (Test-Path $settings.OutputModulePath -PathType Container)) { New-Item $settings.OutputModulePath -ItemType Directory | Out-Null }
    $content | Out-File (Join-Path $settings.OutputModulePath $Filename)
}

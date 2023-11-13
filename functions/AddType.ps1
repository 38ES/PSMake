function AddType {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Base64Encode', Justification='Used in ForEach-Object call')]
    param(
        [scriptblock]$Scriptblock,
        [string]$OutputDirectory = $settings.OutputDirectory,
        [string]$Filename = $settings.ModuleName + ".psm1",
        [switch]$Base64Encode
    )

    $content = & $Scriptblock | ForEach-Object {
        $current = $_
        if($current -is [string]) { Get-ChildItem $current }
        elseif($current -is [System.IO.FileInfo]) { $current }
        else { throw "Invalid object to collate - $_ of type '$($_.GetType())" }
    } | ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        $scriptblockText = $content
        if($Base64Encode) {
            $encodedScriptblock = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($scriptblockText))
            "Add-Type -TypeDefinition ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$encodedScriptblock')))"
        } else {
            "Add-Type -TypeDefinition @'`r`n$scriptblockText`r`n'@`r`n"
        }
    }

    if(-not (Test-Path $OutputDirectory -PathType Container)) { New-Item $OutputDirectory -ItemType Directory | Out-Null }
    if(-not (Test-Path $settings.OutputModulePath -PathType Container)) { New-Item $settings.OutputModulePath -ItemType Directory | Out-Null }
    $content | Out-File (Join-Path $settings.OutputModulePath $Filename) -Append
}

using namespace System.IO

function CopyFiles {
    param(
        [scriptblock]$ScriptBlock,
        [string]$To = $settings.OutputModulePath
    )
    
    if($To -ne $settings.OutputModulePath) { 
        $To = (Resolve-Path (Join-Path $settings.OutputModulePath $To)).Path
    }

    & $ScriptBlock | ForEach-Object {
        if($_ -is [string]) {
            Get-ChildItem $_
        } elseif($_ -is [FileInfo]) {
            $_
        } else {
            throw "Unexpected item to copy - '$_'"
        }
    } | ForEach-Object {
        Copy-Item $_.FullName $To
    }
    
}
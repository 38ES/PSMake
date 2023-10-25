function InvokeWithPSModulePath {
    [CmdletBinding()]
    param(
        [string]$NewPSModulePath,
        [ScriptBlock]$ScriptBlock
    )

    $pe = GetPlatformEnvironment
    
    $seperatorChar = switch($pe.OSPlatform) {
        { $_ -in [System.PlatformID]::MacOSX, [System.PlatformID]::Unix } {
            ':'
        }
        default {
            ";"
        }
    }

    $cache = $env:PSModulePath
    $newList = @()
    $newList += ([System.IO.Path]::GetFullPath($NewPSModulePath))
    $cache.Split($seperatorChar) | ForEach-Object { $newList += $_ }
    
    $env:PSModulePath = [string]::Join($seperatorChar, $newList)
    Write-Verbose "PSModulePath = $($env:PSModulePath)"
    $ps = [PowerShell]::Create([System.Management.Automation.RunspaceMode]::NewRunspace)
    try {
        $ps.AddCommand("Set-Location") | Out-Null
        $ps.AddArgument((Get-Location).Path) | Out-Null
        $ps.AddStatement() | Out-Null
        $ps.AddScript("`$env:PSModulePath=$($env:PSModulePath)") | Out-Null
        $ps.AddStatement() | Out-Null
        $ps.AddCommand("Invoke-Command") | Out-Null
        $ps.AddParameter("ScriptBlock", $ScriptBlock) | Out-Null
        $ps.Invoke()

        if($ps.HasErrors) {
            $ps.Streams.Error | ForEach-Object { Write-Error $_ }
        }
    }
    finally {
        $ps.Dispose()
        $env:PSModulePath = $cache
    }
    # try {
    #     . $ScriptBlock
    # }
    # finally {
    #     $env:PSModulePath = $cache
    # }

}
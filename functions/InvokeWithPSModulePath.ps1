using namespace System.IO

function InvokeWithPSModulePath {
    [CmdletBinding()]
    param(
        [string]$NewPSModulePath,
        [ScriptBlock]$ScriptBlock
    )

    $pe = GetPlatformEnvironment
    
    $seperatorChar = switch($pe.Platform) {
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
    $ps = [PowerShell]::Create([System.Management.Automation.RunspaceMode]::CurrentRunspace)
    try {
        
        $ps.AddCommand("Set-Location") | Out-Null
        $ps.AddArgument((Get-Location).Path) | Out-Null
       
        $ps.AddScript("`$env:PSModulePath='$($env:PSModulePath)'") | Out-Null
        $ps.AddCommand("Import-Module") | Out-Null
        $ps.AddParameter("Name", [Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "make.psd1")) | Out-Null

        
        $ps.AddCommand("Invoke-Command") | Out-Null
        $ps.AddParameter("ScriptBlock", { . $MyInvocation.MyCommand.Module $ScriptBlock }.GetNewClosure()) | Out-Null
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
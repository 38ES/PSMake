using namespace System.IO

function InvokeWithPSModulePath {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'ScriptBlock', Justification = 'ScriptBlock is used within a child scriptblock')]
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

        $ps.AddScript("`$env:PSModulePath='$($env:PSModulePath)'") | Out-Null

        $ps.AddCommand("Invoke-Command") | Out-Null
        $ps.AddParameter("ScriptBlock", { . $MyInvocation.MyCommand.Module $ScriptBlock }.GetNewClosure()) | Out-Null

        $ps.Invoke()

        if($ps.HadErrors) {
            $ps.Streams.Error | ForEach-Object { Write-Error $_; $_.InvocationInfo.PositionMessage }
        }
    }
    finally {
        $ps.Dispose()
        $env:PSModulePath = $cache
    }
}
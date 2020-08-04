function Invoke-Build {
    [CmdletBinding()]
    param(
        [ValidateSet("","build", "clean", "test", "template", "publish")]
        [string]$Command = "build",
        [Parameter(ValueFromRemainingArguments)]
        $Remaining
    )

    
    switch($Command) {

        "template" {
            $ModuleName = $Remaining[0]
            if(-not (test-path ".\$ModuleName" -PathType Container)) { New-Item .\$ModuleName -ItemType Directory | Out-Null }
            if(-not (test-path ".\$ModuleName\functions" -PathType Container)) { New-Item .\$ModuleName\functions -ItemType Directory | Out-Null }
            if(-not (test-path ".\$ModuleName\tests" -PathType Container)) { New-Item .\$ModuleName\tests -ItemType Directory | Out-Null }
            'Get-ChildItem $PSScriptRoot\functions\ -File -Recurse | ForEach-Object { . $_.FullName }`r`n' | Out-File ".\$("$ModuleName\$ModuleName").psm1" -Encoding UTF8
            (Get-Content "$($MyInvocation.MyCommand.Module.ModuleBase)\template.psd1").Replace("%%MODULENAME%%", $ModuleName) | Out-File ".\$ModuleName\build.psd1"
        }

        {$_ -ne "template" } {
            $buildData = Get-BuildSettings .\build.psd1
            $settings = @{}
            $buildData.Keys | Where { -not ($_ -in "build","clean","test","template","publish")  } | % { $settings[$_] = $buildData[$_] }
        }

        { $_ -in "","build" } {
            if(-not (test-path $buildData.OutputDirectory -PathType Container)) { New-Item $buildData.OutputDirectory -ItemType Directory | Out-Null }
        }

        {$_ -in "", "build","clean","test","publish" } {
            if(-not $buildData.ContainsKey($Command)) { throw "Unable to run '$Command' due to build.psd1 not containing a '$Command' scriptblock" }
            (& $buildData[$Command]).InvokeWithContext($null, [PSVariable]::new('settings', $settings), $null)
        }

        default {
            throw "Undefined command '$Command'"
        }
    }
}

New-Alias -Name "make" Invoke-Build -ErrorAction SilentlyContinue

Export-ModuleMember -Function 'Invoke-Build'
Export-ModuleMember -Alias "make"

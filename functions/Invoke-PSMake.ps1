function Invoke-PSMake {
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
            
            'Get-ChildItem $PSScriptRoot\functions\ -File -Recurse | ForEach-Object { . $_.FullName }' | Out-File ".\$("$ModuleName\$ModuleName").psm1" -Encoding UTF8
            $dom = $env:userdomain
            $usr = $env:username
            try {
                $author = ([adsi]"WinNT://$dom/$usr,user").fullname.ToString()
            } catch {
                $author = "$usr$(if($dom) { "@$dom" })"
            }
            
            if(-not (test-path ".\$ModuleName\$ModuleName.psd1" -PathType Leaf)) { New-ModuleManifest -Path ".\$ModuleName\$ModuleName.psd1" -CompanyName "USAF, 38 CEIG/ES" -Copyright "GOTS" -RootModule "$ModuleName.psm1" -ModuleVersion "1.0.0.0" -Author $author }
            (Get-Content "$($MyInvocation.MyCommand.Module.ModuleBase)\template.psd1").Replace("%%MODULENAME%%", $ModuleName) | Out-File ".\$ModuleName\build.psd1"
            Copy-Item "$($MyInvocation.MyCommand.Module.ModuleBase)\Pester5Configuration-local.psd1" ".\$ModuleName\Pester5Configuration-local.psd1"
            Copy-Item "$($MyInvocation.MyCommand.Module.ModuleBase)\Pester5Configuration-cicd.psd1" ".\$ModuleName\Pester5Configuration-cicd.psd1"
        }

        {$_ -ne "template" } {
            $buildData = Get-BuildSettings .\build.psd1 -RemainingArgs $Remaining
            $settings = @{}
            $buildData.Keys | Where-Object { -not ($_ -in "build","clean","test","template","publish")  } | ForEach-Object { $settings[$_] = $buildData[$_] }
            
        }

        { $_ -in "","build" } {
            if(-not (test-path $buildData.OutputDirectory -PathType Container)) { New-Item $buildData.OutputDirectory -ItemType Directory | Out-Null }
            if(-not (test-path $buildData.OutputModulePath -PathType Container)) { New-Item $buildData.OutputModulePath -ItemType Directory | Out-Null }
        }

        { $_ -in "publish", "test"} {
            ${function:RestoreDependencies}.InvokeWithContext($null, [PSVariable]::new("settings", $settings), $null)
        }

        {$_ -in "", "build","clean","test","publish" } {
            if(-not $buildData.ContainsKey($Command)) { throw "Unable to run '$Command' due to build.psd1 not containing a '$Command' scriptblock" }
            if($buildData.ContainsKey("DevRequiredModules")) { RestoreDependencies -RequiredModule $buildData["DevRequiredModules"] }
            InvokeWithPSModulePath -NewPSModulePath $settings.RestoredDependenciesPath -ScriptBlock { (& $buildData[$Command]).InvokeWithContext($null, [PSVariable]::new('settings', $settings), $Remaining) }.GetNewClosure()
        }

        default {
            throw "Undefined command '$Command'"
        }
    }
}

New-Alias -Name "psmake" Invoke-PSMake -ErrorAction SilentlyContinue

Export-ModuleMember -Function 'Invoke-PSMake'
Export-ModuleMember -Alias "psmake"

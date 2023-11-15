using namespace System.Management.Automation
using namespace System.Collections.ObjectModel


function Invoke-PSMake {
    [CmdletBinding()]
    param(
        [ValidateSet("","build", "clean", "test", "template", "publish")]
        [string]$Command = "build"
    )

    DynamicParam {

        if ($Command -eq 'template') {
            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()

            $projectNameParameterAttribute = [ParameterAttribute]@{
                Mandatory = $true
                Position = 2
            }

            $attributeCollection.Add($projectNameParameterAttribute)
            $projectNameParam = [System.Management.Automation.RuntimeDefinedParameter]::new('ProjectName', [string], $attributeCollection)
            $paramDictionary.Add("ProjectName", $projectNameParam)
            return $paramDictionary
        }

        if ($Command -eq 'publish') {
            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $nugetApiKeyAttribute = [ParameterAttribute]@{
                Position = 2
            }
            $attributeCollection.Add($nugetApiKeyAttribute)
            $nugetApiKeyParam = [System.Management.Automation.RuntimeDefinedParameter]::new('NuGetApiKey', [string], $attributeCollection)
            $paramDictionary.Add("NuGetApiKey", $nugetApiKeyParam)
            return $paramDictionary
        }

        if ($Command -eq 'test') {
            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $reportsParameterAttribute = [ParameterAttribute]@{
                Position = 2
            }
            $attributeCollection.Add($reportsParameterAttribute)
            $reportsParam = [System.Management.Automation.RuntimeDefinedParameter]::new('ReportType', [string], $attributeCollection)
            $paramDictionary.Add("ReportType", $reportsParam)
            return $paramDictionary
        }

        if ($Command -eq 'build') {
            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $buildTargetParameterAttribute = [ParameterAttribute]@{
                Position = 2
            }
            $attributeCollection.Add($buildTargetParameterAttribute)
            $buildTargetParam = [System.Management.Automation.RuntimeDefinedParameter]::new('BuildTarget', [string], $attributeCollection)
            $buildTargetParam.Value = "Release"
            $PSBoundParameters["BuildTarget"] = $buildTargetParam.Value
            $paramDictionary.Add("BuildTarget", $buildTargetParam)
            return $paramDictionary
        }
    }

    Begin {
        $invokeArgs = @()
    }

    Process{
        switch($Command) {

            "template" {
                $ModuleName = $PSBoundParameters["ProjectName"]
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
                $buildArgs = @{
                    BuildFilePath = ".\build.psd1"
                }
                if($PSBoundParameters.ContainsKey("BuildTarget")) {
                    $buildArgs.Add("BuildTarget", $PSBoundParameters["BuildTarget"])
                }

                $buildData = Get-BuildSettings @buildArgs
                $settings = @{}
                $buildData.Keys | Where-Object { -not ($_ -in "build","clean","test","template","publish")  } | ForEach-Object { $settings[$_] = $buildData[$_] }

            }

            { $_ -in "","build" } {
                if(-not (test-path $buildData.OutputDirectory -PathType Container)) { New-Item $buildData.OutputDirectory -ItemType Directory | Out-Null }
                if(-not (test-path $buildData.OutputModulePath -PathType Container)) { New-Item $buildData.OutputModulePath -ItemType Directory | Out-Null }
                $invokeArgs += $PSBoundParameters["BuildTarget"]
            }

            { $_ -in "publish", "test"} {
                ${function:RestoreDependencies}.InvokeWithContext($null, [PSVariable]::new("settings", $settings), $null)
            }

            { $_ -eq 'publish' } {
                if($PSBoundParameters.ContainsKey("NuGetApiKey")) {
                    $invokeArgs += $PSBoundParameters["NuGetApiKey"]
                }
            }

            { $_ -eq "test" } {
                if($PSBoundParameters.ContainsKey("ReportType")) {
                    $invokeArgs += $PSBoundParameters["ReportType"]
                }
            }

            {$_ -in "", "build","clean","test","publish" } {
                if(-not $buildData.ContainsKey($Command)) { throw "Unable to run '$Command' due to build.psd1 not containing a '$Command' scriptblock" }
                if($buildData.ContainsKey("DevRequiredModules")) { RestoreDependencies -RequiredModule $buildData["DevRequiredModules"] }
                InvokeWithPSModulePath -NewPSModulePath $settings.RestoredDependenciesPath -ScriptBlock { (& $buildData[$Command]).InvokeWithContext($null, [PSVariable]::new('settings', $settings), $invokeArgs) }.GetNewClosure()
            }

            default {
                throw "Undefined command '$Command'"
            }
        }
    }


    <#
        .SYNOPSIS
        Invokes the PSMake project management tool based on given parameter (defaults to build release)

        .DESCRIPTION
        Builds a PSMake structured project in the current directory based on the build.psd1 file (build, test, clean, plublish)
        or creates the project structure with default settings (template)

        .PARAMETER Command
        Specifies the action to take (build, test, clean, publish, template)

        .INPUTS
        None. Piping unavailable.

        .OUTPUTS
        None. Affects project outputs and runs other test scripts based on the build.psd1 file.

        .EXAMPLE
        PS> PSMake
        # builds a release version of the module specified within build.psd1

        PS> PSMake build release
        # same as above, but explicit

        .EXAMPLE
        PS> PSMake build debug
        # builds the debug version of the module as specified within the build.psd1 Build property-script

        .EXAMPLE
        PS> PSMake clean
        # runs the 'Clean' property-script within build.psd1 (deletes the dist/ folder by default)

        .EXAMPLE
        PS> PSMake test
        # runs the 'Test' property-script within the build.psd1 file

        PS> PSMake test reports
        # runs the 'Test' property-script within the build.psd1 file and passes "reports" value as a parameter to it.

        .EXAMPLE
        PS> PSMake publish
        # runs the 'Publish' property-script within the build.psd1 file

        .EXAMPLE
        PS> PSMake template
        # Initializes a new PSMake project with templated build.psd1, module file, module manifest, specialized folders
    #>
}

New-Alias -Name "psmake" Invoke-PSMake -ErrorAction SilentlyContinue

Export-ModuleMember -Function 'Invoke-PSMake'
Export-ModuleMember -Alias "psmake"

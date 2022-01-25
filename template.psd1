@{
    #
    # Generated template build.psd1 file
    #

    ###
    # REQUIRED - Name of module
    ###
    ModuleName = '%%MODULENAME%%'
    
    ###
    # OPTIONAL - Directory to put the built powershell module
    # DEFAULT IS .\dist
    ###
    # OutputDirectory = '.\dist'

    ###
    # OPTIONAL - Module output directory
    # DEFAULT IS $OutputDirectory\$BuildTarget\$ModuleName
    #ModuleOutputDirectory = ''

    ###
    # OPTIONAL - Default Build Target
    # DEFAULT IS Release
    #DefaultBuildTarget = 'Release'

    ##
    # REQUIRED - Script to build the module 
    ##
    Build = {

        CopyFiles {
            # List of files to copy to the ModuleOutputPath
            "%%MODULENAME%%.psd1"
        }

        Debug {
            # Debug Build Target
            # Only executed when using 'make build debug'

            CopyDirectory {
               'functions'
            }

            CopyFiles {
                '%%MODULENAME%%.psm1'
            }
        }

        Release {
            # Release Build Target (Default)
            # Only executed when targeting release (which is default)
            Collate {
                Get-ChildItem .\functions -Recurse -File
            }

            CodeSign {
                '%%MODULENAME%%.psd1'
                '%%MODULENAME%%.psm1'
            }

        }
    }

    ##
    # REQUIRED - Script to clean (remove) all the build files and folders
    ##
    Clean = {
        if ((Test-Path $settings.OutputDirectory)) {
            Remove-Item $settings.OutputDirectory -Recurse
        }
    }

    ##
    # REQUIRED - Script to publish the built script
    ##
    Publish = {
        param(
            [string]$NuGetAPIKey
        )

        $args1 = @{
            Path = $settings.OutputModulePath
            Repository = 'Di2e'
        }

        if($PSBoundParameters.ContainsKey('NuGetApiKey')) {
            $args1.Add('NuGetApiKey', $NuGetAPIKey)
        }

        import-module PowerShellGet -RequiredVersion 2.2.5
        Publish-Module @args1
    }

    ##
    # REQUIRED - Script to run the unit tests for the module
    ##
    Test = {
        param(
            [Parameter(Position=0)]
            [string]$Target
        )

        if ($PSBoundParameters.ContainsKey("Target") -and $Target -eq "reports") {
            Write-Information "Writing Test Reports!"
        }
        
        $testFiles = Get-ChildItem .\tests -Recurse -File -Filter *Tests.ps1
        $pesterArgs = @{
            Script = $testFiles.FullName
        }
        if ($Target -eq "reports") {
            $pesterArgs.Add('OutputFile', './PesterTestsReport.xml')
            $pesterArgs.Add('OutputFormat', 'NUnitXml')
            $pesterArgs.Add('CodeCoverageOutputFile', './CodeCoverageReport.xml')
            $pesterArgs.Add('CodeCoverageOutputFileFormat', 'JaCoCo')
            $pesterArgs.Add('CodeCoverage', (Get-ChildItem ./functions/* -File -Recurse).FullName)

        }
        
        import-module ".\$($settings.ModuleName).psd1" -force -ErrorAction Stop
        Invoke-Pester @pesterArgs
    }

}
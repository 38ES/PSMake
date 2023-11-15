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

    ###
    # OPTIONAL - Default dependency restoration path
    # DEFAULT IS .dependencies
    #RestoredDependenciesPath = '.dependencies'

    ###
    # OPTIONAL - Restore dependency credential
    # DEFAULT IS $null
    # Can be a PSCredential type, path, or factory scriptblock that returns a PSCredential
    #Credential = $null

    ###
    # OPTIONAL - Specifies PowerShell module required for Development
    # Default is $null
    # List of strings or hashtables specifying modules
    # string - module with that name, any version
    # hashtable - @{
    #     ModuleName = name of the module
    #     RequiredVersion = specific version
    #     ModuleVersion = specific version or higher
    #}
    #DevRequiredModules = ''

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
            # Only executed when using 'PSMake build debug'

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
            Repository = '38Nexus'
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
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Target', Justification = 'Will be used later')]
        param(
            [Parameter(Position=0)]
            [string]$Target
        )

        Invoke-Pester -Configuration (Import-CliXml .\Pester5Configuration.xml)
    }

}
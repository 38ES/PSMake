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
        Remove-Item $settings.OutputDirectory -Recurse
    }

    ##
    # REQUIRED - Script to publish the built script
    ##
    Publish = {
        import-module moduleupdater -force
        Set-LocalRepository $settings.BuildTargetPath
        if(Get-RemoteModule | Where-Object { $_.Name -eq $settings.ModuleName }) {
            Publish-LocalModuleUpdate $settings.ModuleName
        } else {
            Publish-LocalModule $settings.ModuleName
        }
        Reset-LocalRepository
    }

    ##
    # REQUIRED - Script to run the unit tests for the module
    ##
    Test = {
        import-module ".\$($settings.ModuleName).psd1" -force
        $testFiles = Get-ChildItem .\tests -Recurse -File
        Invoke-Pester $testFiles.FullName
    }

}
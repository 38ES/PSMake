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
    # DEFAULT IS $OutputDirectory\$ModuleName
    #ModuleOutputDirectory = ''

    ##
    # REQUIRED - Script to build the module 
    ##
    Build = {
        Collate {
            # List of files to combine into the PSM1 file during build
            Get-ChildItem .\functions\ -Recurse -File
        }

        CopyFiles {
            # List of files to copy to the ModuleOutputPath
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
        Set-LocalRepository $settings.OutputDirectory
        if(Get-RemoteModule | where { $_.Name -eq $settings.ModuleName }) {
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
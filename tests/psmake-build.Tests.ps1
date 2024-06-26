[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','', Justification = 'Pester Tests use variables outside standard scope')]
param()

BeforeDiscovery {
    Import-Module $PSScriptRoot\..\PSMake.psd1 -Force
}

Describe 'Make-Build' {
    Context 'With build.psd1' {
        BeforeAll {
            $fileContents = @"
@{
    ModuleName = 'test'
    Build = { 'Build Invoked' }
    Clean = { 'Clean Invoked' }
}
"@

            # Arrange

            $fileContents | Out-File TestDrive:\build.psd1
            Push-Location TestDrive:\

            #Act

            $output = Invoke-PSMake
            $cleanOutput = Invoke-PSMake clean
        }

        It "Should call 'Build' scriptblock of build.psd1" {
            $output | Should -Be "Build Invoked"
        }

        It "Should call 'Clean' scriptblock of build.psd1" {
            $cleanOutput | Should -Be "Clean Invoked"
        }

        AfterAll {
            Pop-Location
        }

    }

    Context 'Without build.psd1' {
        BeforeAll {
            Push-Location TestDrive:\
            if((test-path TestDrive:\build.psd1)) { Remove-Item TestDrive:\build.psd1 }
        }

        It "Should throw an exception" {
             { Invoke-PSMake } | Should -Throw "No build.psd1 file found!"
        }

        AfterAll {
            Pop-Location
        }
    }
}
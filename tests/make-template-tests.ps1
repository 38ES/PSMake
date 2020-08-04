# Tests for 'make' (Invoke-Make) template
using module "..\make.psm1"

Describe 'Make-Template' {
    Context 'Is Invoked' {
        BeforeAll {
            Push-Location TestDrive:\
        }
        
        # Act
        Invoke-Build template example
        
        It "Should create a folder for the module" {
            (test-path .\example -PathType Container) | Should -Be $true
        }

        It "Should create a tests folder in the module project" {
            (test-path .\example\tests -PathType Container) | Should -Be $true
        }

        It "Should create a functions folder in the module project" {
            (test-path .\example\functions -PathType Container) | Should -Be $true
        }

        It "Should create a powershell module file in the module project" {
            (test-path .\example\example.psm1 -PathType Leaf) | Should -Be $true
        }

        It "Should create a build.psd1 file in the module project" {
            (test-path .\example\build.psd1 -PathType Leaf) | Should -Be $true
        }

        AfterAll {
            Pop-Location
        }
        
    }
}
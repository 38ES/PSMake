BeforeDiscovery {
    Import-Module $PSScriptRoot\..\PSMake.psd1 -Force
}

InModuleScope 'PSMake' {
    Describe "CopyFiles" {
        Context "'To' parameter specified" {
            BeforeAll {
                $pathToResolve = [string]::Empty
                $script:settings = @{ OutputModulePath = "TestDrive:\fake"}
                $resolvedCalled = $false
                $script:copyTo = [string]::Empty

                Mock Resolve-Path {
                    $script:pathToResolve = $Path
                    $script:resolvedCalled = $true
                } -ParameterFilter { $Path }
                
                Mock Get-ChildItem { [pscustomobject]@{FullName = "myfakefile.txt"} }
                
                Mock Copy-Item { $script:copyTo = $Destination }
            }

            It "Should execute without error and no return" {
                $output = CopyFiles { "TestDrive:\My\Fake\file.txt" } -To "TestDrive:\My\Fake\Directory\"
                $output | Should -BeNullOrEmpty
            }

            It "Should Not call Resolve-Path" {
                $script:pathToResolve | Should -BeNullOrEmpty
            }

            It "Should use the settings.outputmodulepath as a base for relative paths" {
                $output = (Get-Command CopyFiles).ScriptBlock.InvokeWithContext($null, [PSVariable]::new("settings", $settings), @({ "fake\relative\path" }, "fake\output\path"))
                $output | Should -BeNullOrEmpty
                $script:copyTo | Should -Be (Join-Path $settings.OutputModulePath "fake\output\path")
            }

        }
    }
}
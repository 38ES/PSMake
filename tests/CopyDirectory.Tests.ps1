BeforeDiscovery {
    Import-Module $PSScriptRoot\..\make.psd1 -Force
}

InModuleScope 'make' {
    Describe "CopyDirectory" {
        Context "'To' parameter specified" {
            BeforeAll {
                $script:pathToResolve = [string]::Empty
                $script:settings = @{ OutputModulePath = "TestDrive:\fake"}
                $resolvedCalled = $false
                $script:copyTo = [string]::Empty
                Mock Resolve-Path {$script:pathToResolve = $Path;  $script:resolvedCalled = $true} -ParameterFilter { $Path }

                Mock Get-ChildItem {}
                Mock Copy-Item { $script:copyTo = $Destination }
            }

            It "Should execute without error and no return" {
                $output = CopyDirectory { "TestDrive:\My\Fake\" } -To "TestDrive:\My\Fake\Directory\"
                $output | Should -BeNullOrEmpty
            }

            It "Should Not call Resolve-Path" {
                $pathToResolve | Should -BeNullOrEmpty
            }

            It "Should use the settings.outputmodulepath as a base if relative" {
                $output = (Get-Command CopyDirectory).ScriptBlock.InvokeWithContext($null, [PSVariable]::new("settings", $settings), @({ "my/relative/path" }, "destination/relative/path"))
                $output | Should -BeNullOrEmpty
                $copyTo | Should -Be (Join-Path $settings.OutputModulePath "destination/relative/path")
            }

        }
    }
}
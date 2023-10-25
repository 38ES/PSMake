BeforeDiscovery {
    Import-Module $PSScriptRoot/../make.psd1 -Force
}

InModuleScope 'make' {
    Describe 'GetPlatformEnvironment' {
        BeforeAll {
            $pe = GetPlatformEnvironment
        }

        It 'Should not return null' {
            $pe | Should -Not -BeNullOrEmpty
        }

        It 'Should contain a PlatformID object for the Platform property' {
            $pe.Platform | Should -Not -BeNullOrEmpty
            $pe.Platform | Should -BeOfType [System.PlatformID]
        }

        It 'Should contain a Version for OSVersion property' {
            $pe.OSVersion | Should -Not -BeNullOrEmpty
            $pe.OSVersion | Should -BeOfType [System.Version]
        }

        It 'Should contain a string for a OSVersionString property' {
            $pe.OSVersionString | Should -Not -BeNullOrEmpty
            $pe.OSVersionString | Should -BeOfType [string]
        }

        It 'Should contain a version for the PSVersion property' {
            $pe.PSVersion | Should -Not -BeNullOrEmpty
            $pe.PSVersion | Should -BeOfType [System.Version]
        }
    }
}
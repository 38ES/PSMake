using namespace System.IO

function GetRestoreCredential {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConverttoSecureStringWithPlainText', '', Justification = '-AsPlainText is required on *nix systems')]
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param()

    # Environment wins ALWAYS
    if ($env:POWERSHELL_REPO_USR -and $env:POWERSHELL_REPO_PW) {
        return [pscredential]::new($env:POWERSHELL_REPO_USR, (ConvertTo-SecureString -String $env:POWERSHELL_REPO_PW -AsPlainText -Force))
    }

    # Custom set RestoreCredential
    if($settings.RestoreCredential) {
        if ($settings.RestoreCredential -is [scriptblock]) {
            # CustomFactory
            $output = $settings.RestoreCredential.InvokeWithContext($null, [psvariable]::new("settings", $settings), $null)
            if (-not $output -or -not ($output -is [pscredential])) {
                throw "RestoreCredential Factory did not return a PSCredential object!"
            }
            return $output
        }
        elseif ($settings.RestoreCredential -is [string]) {

            # Configured Path
            if (-not (test-path $settings.RestoreCredential -PathType Leaf)) {
                throw "RestoreCredential path '$($settings.RestoreCredential)' does not exist or is not a file!"
            }

            [FileInfo]$fileInfo = [FileInfo]::new($settings.RestoreCredential)

            $obj = switch($fileInfo.Extension.ToLower()) {
                ".json" {
                    Get-Content $settings.RestoreCredential -Raw | ConvertFrom-Json -ErrorAction Stop
                }
                ".xml" {
                    Import-CliXml $settings.RestoreCredential -ErrorAction Stop
                }
                default {
                    throw "RestoreCredential in file '$($settings.RestoreCredential)' not in json or xml format!"
                }
            }

            $usernameProperty = $obj.PSObject.Properties.Match("UserName")
            $passwordProperty = $obj.PSObject.Properties.Match("Password")

            if ($null -eq $usernameProperty -or $null -eq $passwordProperty) {
                throw "RestoreCredential in file '$($settings.RestoreCredential)' missing required username and password properties!"
            }

            return [pscredential]::new($usernameProperty.Value, (ConvertTo-SecureString -String $passwordProperty.Value -AsPlainText -Force))
        }
        elseif ($settings.RestoreCredential -is [PSCredential]) {
            return $settings.RestoreCredential
        }
        else {
            throw 'Restore Credential is not a factory, file path, or PSCredential!'
        }
    }

    # Default - $null
    return $null
}
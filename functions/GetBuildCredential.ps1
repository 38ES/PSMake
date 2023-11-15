using namespace System.IO

function GetBuildCredential {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConverttoSecureStringWithPlainText', '', Justification = '-AsPlainText is required on *nix systems')]
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param(
        $Settings = $settings
    )

    # Environment wins ALWAYS
    if ($env:POWERSHELL_REPO_USR -and $env:POWERSHELL_REPO_PW) {
        return [pscredential]::new($env:POWERSHELL_REPO_USR, (ConvertTo-SecureString -String $env:POWERSHELL_REPO_PW -AsPlainText -Force))
    }

    # Custom set Credential
    if($null -ne $Settings.Credential) {
        if ($Settings.Credential -is [scriptblock]) {
            # CustomFactory
            Write-Verbose "Credential is a scriptblock, Invoking now."
            $output = $Settings.Credential.InvokeWithContext($null, [psvariable]::new("settings", $Settings), $null)
            if (-not $output -or -not ($output -is [pscredential])) {
                throw "Credential Factory did not return a PSCredential object!"
            }
            return $output
        }
        elseif ($Settings.Credential -is [string]) {
            Write-Verbose 'Credential is a string. Checking path.'
            # Configured Path
            if (-not (test-path $Settings.Credential -PathType Leaf)) {
                throw "Credential path '$($Settings.Credential)' does not exist or is not a file!"
            }

            [FileInfo]$fileInfo = [FileInfo]::new($Settings.Credential)

            $obj = switch($fileInfo.Extension.ToLower()) {
                ".json" {
                    Write-Verbose 'JSON credential detected.'
                    Get-Content $Settings.Credential -Raw | ConvertFrom-Json -ErrorAction Stop
                }
                ".xml" {
                    Write-Verbose 'CliXml credential detected.'
                    Import-CliXml $Settings.Credential -ErrorAction Stop
                }
                default {
                    throw "Credential in file '$($Settings.Credential)' not in json or xml format!"
                }
            }

            $usernameProperty = $obj.PSObject.Properties.Match("UserName")
            $passwordProperty = $obj.PSObject.Properties.Match("Password")

            if ($null -eq $usernameProperty -or $null -eq $passwordProperty) {
                throw "Credential in file '$($Settings.Credential)' missing required username and password properties!"
            }

            return [pscredential]::new($usernameProperty.Value, (ConvertTo-SecureString -String $passwordProperty.Value -AsPlainText -Force))
        }
        elseif ($Settings.Credential -is [PSCredential]) {
            Write-Verbose 'Credential property is already a PSCredential.'
            return $Settings.Credential
        }
        else {
            throw 'Restore Credential is not a factory, file path, or PSCredential!'
        }
    }
    Write-Verbose 'No credential detected. Returning null.'
    # Default - $null
    return $null
}
param(
    [string]$NuGetAPIKey,
    [string]$Username,
    [securestring]$Password
)

try {
    $cred = [pscredential]::new($Username, $Password)
    Register-PSRepository Di2e `
        -SourceLocation https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/ `
        -PublishLocation https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/ `
        -Credential $cred `
        -InstallationPolicy Trusted `
        -ErrorAction Stop `
        -WarningAction -Stop

    make clean
    make
    Publish-Module -Path ./dist/Release/make -NuGetApiKey $NuGetAPIKey -Repository Di2e
} catch {
    Write-Error $_
    exit 1
}
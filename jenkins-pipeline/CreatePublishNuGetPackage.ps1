param(
    [string]$SourceLocation = 'https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/',
    [string]$PublishLocation = 'https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/',
    [string]$NuGetAPIKey,
    [string]$Username,
    [securestring]$Password
)

try {
    $cred = [pscredential]::new($Username, $Password)
    Register-PSRepository Di2e `
        -SourceLocation $SourceLocation `
        -PublishLocation $PublishLocation `
        -Credential $cred `
        -InstallationPolicy Trusted `
        -ErrorAction Stop `
        -WarningAction Stop
    import-module $PSScriptRoot\..\make.psd1
    make clean
    make
    Publish-Module -Path ./dist/Release/make -NuGetApiKey $NuGetAPIKey -Repository Di2e -ErrorAction Stop
} catch {
    Write-Error $_
    exit 1
}
param(
    [string]$Name = "Di2e",
    [string]$SourceLocation = 'https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/',
    [string]$PublishLocation = 'https://nexus.di2e.net/nexus3/repository/Private_CEIG_NuGet/',
    [string]$NuGetAPIKey,
    [string]$Username,
    [securestring]$Password
)

try {
    $cred = [pscredential]::new($Username, $Password)
    Register-PackageSource -Name $Name -Credential $cred -Location $SourceLocation -ProviderName NuGet
    Register-PSRepository $Name `
        -SourceLocation $SourceLocation `
        -PublishLocation $PublishLocation `
        -Credential $cred `
        -InstallationPolicy Trusted `
        -ErrorAction Stop `
        -WarningAction Stop
    import-module $PSScriptRoot\..\make.psd1
    make clean
    make
    # Check if the repo is there
    Find-Module -Repository $Name -Credential $cred
    Publish-Module -Path ./dist/Release/make -NuGetApiKey $NuGetAPIKey -Repository $Name -Credential $cred -ErrorAction Stop
} catch {
    Write-Error $_
    exit 1
}
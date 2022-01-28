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
    Register-PackageSource -Name $Name -Credential $cred -Location $SourceLocation -ProviderName NuGet | Out-Null
    Register-PSRepository $Name `
        -SourceLocation $SourceLocation `
        -PublishLocation $PublishLocation `
        -Credential $cred `
        -InstallationPolicy Trusted `
        -ErrorAction Stop `
        -WarningAction Stop
    
    Publish-Module -Path ./dist/Release/make -NuGetApiKey $NuGetAPIKey -Repository $Name -Credential $cred -ErrorAction Stop -Force
} catch {
    Write-Error $_
    exit 1
}
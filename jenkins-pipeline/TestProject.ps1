try {
    Import-Module Pester -MinimumVersion 4.0 -MaximumVersion 4.99 -ErrorAction Stop
    Import-Module ./make.psd1 -ErrorAction Stop
} catch {
    Write-Error $_
    exit 1
}
make test
exit 0
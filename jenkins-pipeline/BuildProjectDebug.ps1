try {
    Import-Module ./make.psd1 -ErrorAction Stop
    make clean -ErrorAction Stop
    make build debug -ErrorAction Stop
} catch {
    Write-Error $_
    exit 1
}
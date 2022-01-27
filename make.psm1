# Import System.Security from GAC if Windows PowerShell is being used
if ( ([version]$PSVersionTable.PSVersion).Major -lt 6) {
    $asm = [System.Reflection.Assembly]::LoadFromPartialName("System.Seurity")
    if ($null -eq $asm) {
        throw 'Unable to load System.Security from GAC for Windows PowerShell'
    }
}

# Include all the functions in the functions folder
Get-ChildItem "$PSScriptRoot\functions\" -Recurse -File | ForEach-Object { . $_.FullName }

# Include all the functions in the functions folder
Get-ChildItem "$PSScriptRoot\functions\" -Recurse -File | ForEach-Object { . $_.FullName }

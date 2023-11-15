[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Justification = 'BuildSettings is a type')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Scope='Function', Justification = 'BuildSettings is a type')]
param()

function Validate-BuildSettings {
    param(
        [hashtable]$Settings
    )

    # Check for module name
    if(-not $Settings.ContainsKey("ModuleName")) { throw "Required Property 'ModuleName' is not defined." }
    if(-not ($Settings["ModuleName"] -match "^[a-zA-Z][a-zA-Z0-9-_]*$")) { throw "Property 'ModuleName' ($($Settings["ModuleName"])) is invalid." }

    # Check for Build scriptblock
    if(-not $Settings.ContainsKey("Build")) { throw "Required Property 'Build' is not defined" }
    if(-not $Settings["Build"] -is [scriptblock]) { throw "Property Build is not a scriptblock! ($($Settings.Build))" }

    # Check for Build scriptblock
    if(-not $Settings.ContainsKey("Clean")) { throw "Required Property 'Clean' is not defined" }
    if(-not $Settings["Clean"] -is [scriptblock]) { throw "Property Clean is not a scriptblock! ($($Settings.Clean))" }

    # Check if Valid BuildTarget
    if(-not $Settings.ContainsKey("BuildTarget")) { throw "Required Property 'BuildTarget' is not defined" }
    if(-not $Settings["BuildTarget"] -is [string]) { throw "Property 'BuildTarget' not a string! ($($Settings.BuildTarget))" }
    if(-not @("Release", "Prerelease", "Debug") -contains $Settings["BuildTarget"]) { throw "Property 'BuildTarget' is not a valid build target (Release, Debug)! ($($Settings.BuildTarget))" }
}
using namespace System.Security.Cryptography.X509Certificates
using namespace System.IO

function CodeSign {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", 'BaseDirectory', Justification = "Used in ForEach-Object scriptblock")]
    Param(
        [ScriptBlock]$ScriptBlock,
        [string]$BaseDirectory = $settings.OutputModulePath,
        [string]$CertificatePath = 'Cert:\CurrentUser\My',
        [string]$TimestampServer = 'http://timestamp.comodoca.com/authenticode'
    )

    [X509Certificate2[]] $signingCerts = Get-ChildItem $CertificatePath -Recurse | Where-Object {
        $_ -is [X509Certificate2] -and ($_.EnhancedKeyUsageList.FriendlyName) -contains 'Code Signing'
    }

    if(-not $signingCerts) { throw "No Code Signing Certs Found!"}

    [X509Certificate2Collection]$selection = [X509Certificate2UI]::SelectFromCollection($signingCerts, "Select Certificate", "Select Code Signing Certificate", [X509SelectionFlag]::SingleSelection)

    if($selection.Count -ne 1) {
        throw 'No Code Signing Certificate Selected!'
    }

    [X509Certificate2]$cert = $selection[0]
    $authenticodeArgs = @{
        "Certificate" = $cert
        "IncludeChain" = 'all'
    }

    if($TimestampServer) {
        $authenticodeArgs["TimestampServer"] = $TimestampServer
    }

    $files = & $ScriptBlock | ForEach-Object {
        if($_ -is [string]) {
            Get-ChildItem (Resolve-Path (Join-Path $BaseDirectory $_)) -File
        } elseif($_ -is [FileInfo]) {
            $_
        } else {
            throw "Item $_ neither a path or file. Cannot Code Sign"
        }
    }

    $authenticodeArgs["FilePath"] = $files.FullName

    Set-AuthenticodeSignature @authenticodeArgs | Out-Null
}
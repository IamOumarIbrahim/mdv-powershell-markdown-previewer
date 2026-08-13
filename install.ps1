# mdv Installer for PowerShell
# Supports PowerShell 7+ (pwsh) and Windows PowerShell 5.1

$ErrorActionPreference = "Stop"

$profiles = @(
    "$env:USERPROFILE\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

$mdvFunction = @'
# =====================================================================
# mdv — Fast, Zero-Limit GitHub Dark Mode Markdown Previewer
# =====================================================================
function mdv {
    param(
        [Alias("a")]
        [switch]$All,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Targets
    )

    function Format-MdPreview($fileItem) {
        if (-not (Test-Path $fileItem.FullName)) { return }
        $raw = Get-Content -Raw $fileItem.FullName
        if (-not $raw) { return }
        
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
        $base64 = [Convert]::ToBase64String($bytes)
        $fileDir = $fileItem.DirectoryName.Replace('\', '/')
        $title = $fileItem.Name

        $template = @"
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <base href="file:///$fileDir/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown-dark.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>
    <style>
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            margin: 0;
            padding: 2rem;
            display: flex;
            justify-content: center;
            font-family: -apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;
        }
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 1012px;
            width: 100%;
            padding: 45px;
            background-color: #0d1117;
            border: 1px solid #30363d;
            border-radius: 6px;
        }
        .markdown-body img {
            max-width: 100%;
            box-sizing: content-box;
            background-color: transparent;
        }
        .katex {
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <article class="markdown-body" id="content"></article>
    <script>
        const b64 = "$base64";
        const binaryStr = atob(b64);
        const bytes = Uint8Array.from(binaryStr, c => c.charCodeAt(0));
        const rawText = new TextDecoder("utf-8").decode(bytes);

        const contentEl = document.getElementById('content');
        contentEl.innerHTML = marked.parse(rawText);
        renderMathInElement(contentEl, {
            delimiters: [
                {left: '$$', right: '$$', display: true},
                {left: '$', right: '$', display: false},
                {left: '\\(', right: '\\)', display: false},
                {left: '\\[', right: '\\]', display: true}
            ],
            throwOnError: false
        });
    </script>
</body>
</html>
"@

        $cleanName = [RegEx]::Replace($fileItem.Name, '[^a-zA-Z0-9_-]', '_')
        $outPath = Join-Path $env:TEMP "mdv_$cleanName.html"
        Set-Content -Path $outPath -Value $template -Encoding UTF8
        Start-Process $outPath
    }

    if ($All -or ($Targets -and ($Targets[0] -eq '-all' -or $Targets[0] -eq '-a'))) {
        $files = Get-ChildItem -Path . -Filter *.md
        if (-not $files) {
            Write-Warning "No .md files found in current directory."
            return
        }
        foreach ($f in $files) {
            Format-MdPreview $f
            Start-Sleep -Milliseconds 150
        }
    }
    elseif (-not $Targets) {
        $files = Get-ChildItem -Path . -Filter *.md
        if ($files) {
            Format-MdPreview $files[0]
        } else {
            Write-Warning "No .md files found in current directory."
        }
    }
    else {
        foreach ($t in $Targets) {
            $item = Get-Item $t -ErrorAction SilentlyContinue
            if ($item) {
                Format-MdPreview $item
            } else {
                Write-Warning "File not found: $t"
            }
        }
    }
}
'@

$installedCount = 0
foreach ($p in $profiles) {
    $dir = Split-Path $p
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    $existing = ""
    if (Test-Path $p) {
        $existing = Get-Content -Raw $p -ErrorAction SilentlyContinue
    }

    if ($existing -notlike "*function mdv*") {
        Add-Content -Path $p -Value "`n$mdvFunction`n" -Force
        Write-Host "[+] Installed mdv to: $p" -ForegroundColor Green
    } else {
        Set-Content -Path $p -Value $mdvFunction -Force
        Write-Host "[*] Updated mdv in: $p" -ForegroundColor Cyan
    }
    $installedCount++
}

Write-Host "`n[SUCCESS] mdv installed into $installedCount PowerShell profiles!" -ForegroundColor Green
Write-Host "Restart your terminal or run '. `$PROFILE' to start using 'mdv'!" -ForegroundColor Yellow

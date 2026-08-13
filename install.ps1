# mdv-powershell-markdown-previewer Installer (v1.2.0)
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
# mdv-powershell-markdown-previewer (v1.2.0)
# Fast, Zero-Limit GitHub Dark Mode & Obsidian Properties Previewer
# =====================================================================
function mdv {
    param(
        [Alias("a")]
        [switch]$All,

        [Alias("af")]
        [switch]$AllFolders,

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
    <script src="https://cdn.jsdelivr.net/npm/js-yaml@4.1.0/dist/js-yaml.min.js"></script>
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
        .obsidian-properties {
            margin-bottom: 1.5rem;
            padding: 14px 18px;
            background-color: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            font-size: 0.88rem;
        }
        .properties-header {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
            color: #8b949e;
            margin-bottom: 12px;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
        }
        .properties-table {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .prop-row {
            display: flex;
            align-items: flex-start;
            padding: 3px 0;
        }
        .prop-key {
            width: 160px;
            min-width: 160px;
            color: #8b949e;
            font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
            padding-top: 2px;
        }
        .prop-val {
            color: #c9d1d9;
            flex: 1;
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            align-items: center;
        }
        .prop-pill {
            background-color: #21262d;
            color: #58a6ff;
            border: 1px solid #30363d;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
        }
        .prop-pill.tag-pill {
            background-color: #1f6beb22;
            color: #79c0ff;
            border-color: #1f6beb66;
        }
        .prop-pill.author-pill {
            background-color: #23863622;
            color: #56d364;
            border-color: #23863666;
        }
        .prop-null {
            color: #484f58;
            font-style: italic;
        }
        .prop-link {
            color: #58a6ff;
            text-decoration: none;
        }
        .prop-link:hover {
            text-decoration: underline;
        }
        .katex {
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <article class="markdown-body" id="content"></article>
    <script>
        function escapeHtml(str) {
            return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }

        function formatPropValue(key, val) {
            if (val === null || val === undefined) {
                return '<span class="prop-null">null</span>';
            }
            if (typeof val === 'boolean') {
                return `<input type="checkbox" disabled ${val ? 'checked' : ''} style="margin:0; cursor:default;" />`;
            }
            if (Array.isArray(val)) {
                const kLower = String(key).toLowerCase();
                const isTag = kLower === 'tags' || kLower === 'manar_relevance';
                const isAuthor = kLower === 'authors';
                let pillClass = 'prop-pill';
                if (isTag) pillClass += ' tag-pill';
                if (isAuthor) pillClass += ' author-pill';

                return val.map(v => `<span class="${pillClass}">${escapeHtml(v)}</span>`).join('');
            }
            const valStr = String(val);
            if (valStr.startsWith('http://') || valStr.startsWith('https://')) {
                return `<a href="${escapeHtml(valStr)}" target="_blank" class="prop-link">${escapeHtml(valStr)}</a>`;
            }
            if (typeof val === 'object') {
                return `<pre style="margin:0; font-size:0.8rem; background:transparent; border:none;">${escapeHtml(JSON.stringify(val, null, 2))}</pre>`;
            }
            return escapeHtml(valStr);
        }

        try {
            const b64 = "$base64";
            const binaryStr = atob(b64);
            const bytes = Uint8Array.from(binaryStr, c => c.charCodeAt(0));
            const rawText = new TextDecoder("utf-8").decode(bytes);

            let bodyText = rawText;
            let propsHtml = '';

            const fmMatch = rawText.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
            if (fmMatch) {
                try {
                    if (typeof jsyaml !== 'undefined') {
                        const parsed = jsyaml.load(fmMatch[1]);
                        if (parsed && typeof parsed === 'object' && Object.keys(parsed).length > 0) {
                            propsHtml = '<div class="obsidian-properties"><div class="properties-header"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg> Properties</div><div class="properties-table">';
                            for (const [k, v] of Object.entries(parsed)) {
                                propsHtml += `<div class="prop-row"><div class="prop-key">${escapeHtml(k)}</div><div class="prop-val">${formatPropValue(k, v)}</div></div>`;
                            }
                            propsHtml += '</div></div>';
                            bodyText = rawText.substring(fmMatch[0].length);
                        }
                    }
                } catch (e) {
                    console.error("YAML Parse Error:", e);
                }
            }

            const contentEl = document.getElementById('content');
            const parsedMarkdown = (typeof marked !== 'undefined') ? marked.parse(bodyText) : escapeHtml(bodyText);
            contentEl.innerHTML = propsHtml + parsedMarkdown;

            if (typeof renderMathInElement !== 'undefined') {
                renderMathInElement(contentEl, {
                    delimiters: [
                        {left: '$$', right: '$$', display: true},
                        {left: '$', right: '$', display: false},
                        {left: '\\(', right: '\\)', display: false},
                        {left: '\\[', right: '\\]', display: true}
                    ],
                    throwOnError: false
                });
            }
        } catch (err) {
            console.error("Render Error:", err);
            document.getElementById('content').innerHTML = '<div style="color:#f85149; padding:20px;">Render Error: ' + escapeHtml(err.message) + '</div>';
        }
    </script>
</body>
</html>
"@

        $cleanName = [RegEx]::Replace($fileItem.Name, '[^a-zA-Z0-9_-]', '_')
        $hash = [Math]::Abs($fileItem.FullName.GetHashCode())
        $outPath = Join-Path $env:TEMP "mdv_${cleanName}_$hash.html"
        Set-Content -Path $outPath -Value $template -Encoding UTF8
        Start-Process $outPath
    }

    $isAllFolders = $AllFolders -or ($Targets -and ($Targets[0] -eq '-allf' -or $Targets[0] -eq '-af'))
    $isAllCurrent = $All -or ($Targets -and ($Targets[0] -eq '-all' -or $Targets[0] -eq '-a'))

    if ($isAllFolders) {
        $files = Get-ChildItem -Path . -Filter *.md -Recurse -File
        if (-not $files) {
            Write-Warning "No .md files found in current directory or subdirectories."
            return
        }
        foreach ($f in $files) {
            Format-MdPreview $f
            Start-Sleep -Milliseconds 150
        }
    }
    elseif ($isAllCurrent) {
        $files = Get-ChildItem -Path . -Filter *.md -File
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
        $files = Get-ChildItem -Path . -Filter *.md -File
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
        Write-Host "Installed mdv to: $p" -ForegroundColor Green
    } else {
        Set-Content -Path $p -Value $mdvFunction -Force
        Write-Host "Updated mdv in: $p" -ForegroundColor Cyan
    }
    $installedCount++
}

Write-Host "`nSUCCESS: mdv (v1.2.0) installed into $installedCount PowerShell profiles." -ForegroundColor Green
Write-Host "Restart your terminal or run '. `$PROFILE' to start using mdv." -ForegroundColor Yellow

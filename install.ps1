# mdv-powershell-markdown-previewer Installer (v1.2.0)
# Supports PowerShell 7+ (pwsh) and Windows PowerShell 5.1

$ErrorActionPreference = "Stop"

$profiles = @(
    "$env:USERPROFILE\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

$mdvFunction = Get-Content -Raw "C:\Users\omarb\.gemini\antigravity\brain\7f6823ea-3198-40e7-9188-9fe598673bc9\scratch\function_body.ps1"

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

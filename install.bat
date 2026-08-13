@echo off
title Installing mdv - Markdown Viewer for PowerShell
echo ========================================================
echo  mdv — Fast, Zero-Limit GitHub Dark Mode Markdown Previewer
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
echo ========================================================
echo  Installation complete!
echo  Restart your PowerShell terminal or run: . $PROFILE
echo  Then try: mdv -all
echo ========================================================
echo.
pause

# refresh — pull the partner's latest shared files (Windows / PowerShell).
$ErrorActionPreference = "Stop"
$Bridge = Split-Path -Parent $PSScriptRoot
Set-Location $Bridge
Write-Host "Refreshing bridge..."
git pull --rebase --autostash
Write-Host "Up to date. Shared files:"
Get-ChildItem "$Bridge\shared" -File -Recurse | Where-Object { $_.Name -ne ".gitkeep" } | ForEach-Object { "   - $($_.Name)" }

# clear — leave the bridge (Windows / PowerShell). Local only; partner unaffected.
$ErrorActionPreference = "Stop"
$Bridge = Split-Path -Parent $PSScriptRoot
$Parent = Split-Path -Parent $Bridge
$Name   = Split-Path -Leaf $Bridge

Write-Host "This disconnects YOUR machine from the bridge."
Write-Host "Removing local folder: $Bridge"
$ans = Read-Host "Type 'leave' to confirm"
if ($ans -ne "leave") { Write-Host "Aborted."; exit 1 }

$pidFile = Join-Path $Bridge ".watch.pid"
if (Test-Path $pidFile) {
  try { Stop-Process -Id (Get-Content $pidFile) -ErrorAction SilentlyContinue } catch {}
  Remove-Item $pidFile -ErrorAction SilentlyContinue
}
$gi = Join-Path $Parent ".gitignore"
if (Test-Path $gi) { (Get-Content $gi) | Where-Object { $_ -ne "$Name/" } | Set-Content $gi }

Set-Location $Parent
Remove-Item -Recurse -Force $Bridge
Write-Host "You've left the bridge. Local clone removed."

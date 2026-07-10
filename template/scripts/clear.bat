@echo off
REM Double-click to leave the bridge. Uses Git Bash if present, else PowerShell.
where bash >/dev/null 2>/dev/null && ( bash "%~dp0clear.sh" ) || ( powershell -ExecutionPolicy Bypass -File "%~dp0clear.ps1" )
pause

@echo off
REM Double-click to pull partner updates. Uses Git Bash if present, else PowerShell.
where bash >/dev/null 2>/dev/null && ( bash "%~dp0refresh.sh" ) || ( powershell -ExecutionPolicy Bypass -File "%~dp0refresh.ps1" )
pause

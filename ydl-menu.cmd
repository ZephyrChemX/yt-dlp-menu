@echo off
REM Run the PowerShell menu script (bypass policy for this file only)
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ydl-menu.ps1"

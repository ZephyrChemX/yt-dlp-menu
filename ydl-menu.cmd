@echo off
REM Jalankan ydl-menu dengan URL dari clipboard
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ydl-menu.ps1" -Clipboard

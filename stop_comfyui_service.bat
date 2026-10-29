@echo off
chcp 65001 >nul
powershell -NoProfile -Command "$owning = (Get-NetTCPConnection -LocalPort 8188 -ErrorAction SilentlyContinue).OwningProcess; Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'python.exe' -and (($_.CommandLine -like '*ComfyUI*' -and $_.CommandLine -like '*main.py*') -or $owning -contains $_.ProcessId) } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
echo ComfyUI service stopped.

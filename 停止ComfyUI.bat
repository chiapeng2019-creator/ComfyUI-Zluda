@echo off
chcp 65001 >nul
echo 正在停止 ComfyUI...
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'zluda.exe') -and $_.CommandLine -like '*ComfyUI*' -and $_.CommandLine -notlike '*sdxl_train_network.py*' -and $_.CommandLine -notlike '*anima_train_network.py*' -and $_.CommandLine -notlike '*kohya_ss*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
echo.
echo ComfyUI 已停止（若上方没有报错信息）。
echo 网页会立即失去连接，关闭浏览器标签页即可。
pause

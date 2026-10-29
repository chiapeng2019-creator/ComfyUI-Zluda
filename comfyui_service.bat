@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "PYTHON=%~dp0venv\Scripts\python.exe"
set "PYTHONIOENCODING=utf-8"
copy /Y "comfy\customzluda\zluda-native.py" "comfy\zluda.py" >NUL
"%PYTHON%" main.py >> "user\comfyui_service.log" 2>&1

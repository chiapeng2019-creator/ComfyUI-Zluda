@echo off
chcp 65001 >nul
cd /d "%~dp0"

set "PYTHON=%~dp0venv\Scripts\python.exe"
set "PYTHONIOENCODING=utf-8"

:: Native NVIDIA CUDA path (RTX 3070 Ti). 官方基座，不再需要 ZLUDA/ROCm 任何铺垫。

echo [INFO] Starting ComfyUI with native NVIDIA CUDA...
"%PYTHON%" main.py --auto-launch
pause

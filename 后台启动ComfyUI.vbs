' Native NVIDIA CUDA launcher (RTX 3070 Ti).
' Runs comfyui-nvidia.bat hidden; browser opens http://127.0.0.1:8188.
' D:\TOOLS\ComfyUI is currently a junction to the old ComfyUI-Zluda folder;
' after the final rename script is run, the same path points to the real folder.
Set ws = CreateObject("WScript.Shell")
ws.CurrentDirectory = "D:\TOOLS\ComfyUI"
ws.Run """D:\TOOLS\ComfyUI\comfyui-nvidia.bat""", 0, False

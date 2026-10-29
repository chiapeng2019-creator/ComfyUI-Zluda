Set ws = CreateObject("WScript.Shell")
ws.CurrentDirectory = "D:\TOOLS\ComfyUI"
ws.Run """D:\TOOLS\ComfyUI\comfyui_service.bat""", 0, False

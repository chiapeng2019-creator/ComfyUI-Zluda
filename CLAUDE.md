# ComfyUI（本机 AI 生图，RTX 3070 Ti 原生 CUDA）

2026-10-22 从 RX 6650 XT + ZLUDA 迁移到 RTX 3070 Ti（8GB，驱动 610.88），改为原生 CUDA。旧的 ZLUDA 运行时/启动器已清理；仓库内的 `patchzluda*.bat`/`install-*.bat` 仅作历史保留，**不要在 NVIDIA 卡上使用**。

## 启动与使用
- 启动（无窗口后台）：双击 `后台启动ComfyUI.vbs`（内部调用 `comfyui-nvidia.bat`，原生 CUDA）
- 启动（有窗口）：双击 `comfyui-nvidia.bat`
- 停止：双击 `停止ComfyUI.bat`（按命令行匹配 ComfyUI 的 python/zluda 进程）；或关闭启动黑窗口
- 网页 http://127.0.0.1:8188（浏览器只是遥控器，关标签≠关服务）
- 旧 ZLUDA 启动器已删除（`zluda\` 运行时、`comfyui-user.bat`、`后台启动ComfyUI-ZLUDA.vbs` 均已清理）；仓库内 `install-*.bat`/`comfyui.bat` 为跟踪的历史脚本，回 AMD 时可重建
- 2026-10-23 改名已完成：`D:\TOOLS\ComfyUI` 已是真实目录，旧 `ComfyUI-Zluda` 已不存在；`D:\TOOLS\完成ComfyUI改名.bat` 仅遗留可删
- 用户工作流：`user\default\workflows\`（网页「工作流 → 打开 → 用户工作流」；模板在 venv\Lib\site-packages\comfyui_workflow_templates_json\templates\）
- 出图：网页「工作流 → 浏览模板」加载模板（默认空白工作流没有保存节点，会报错）
- 图片输出：`output\`；模型放 `models\checkpoints\` / `models\diffusion_models\`
- 用户偏好：**角色相关图片统一放 `output/characters/<角色名>/`，一个角色一个文件夹，从初稿到定稿的中间图都在里面**；- 用户偏好：**出图默认 1024×1024，有明确要求才用其他尺寸**；**生成的图片不要立即删除，等确认终稿后再清理中间产物**；1920×1080 用「1920x1080动漫放大」工作流（AnimeSharp 超分）
- 参考图：`input\starrail\`、`input\角色\`、`input\nsfw\`；分类/风格测试产物在 `output\classify_test\`

## 当前环境
- venv：torch 2.11.0+cu130、torchvision 0.26.0+cu130、torchaudio 2.11.0+cu130、numpy 1.26.4；原生 CUDA 可识别 3070 Ti
- 启动器 `comfyui-nvidia.bat` 会把 `comfy/customzluda/zluda-native.py` 复制为 `comfy/zluda.py`（空实现，无 ZLUDA/ROCm 副作用）
- cuDNN 在原生启动器下未禁用；旧 `comfyui-user.bat` 仍会设置 `TORCH_BACKENDS_CUDNN_ENABLED=0`，仅历史
- 2026-10-23 已升级 cu130（torch 2.11.0）；cu130 的 torchaudio 最高只到 2.11.0，不要单独升 torch 到 2.14（无配套 torchaudio）。旧 cu118 备份在 `D:\TOOLS\ComfyUI_torch_backup_cu118`（5.4GB），回滚：`venv\Scripts\python.exe -m pip install --force-reinstall --no-deps torch==2.7.0+cu118 torchvision==0.22.0+cu118 torchaudio==2.7.0+cu118 --index-url https://download.pytorch.org/whl/cu118`
- 8GB 显存：SDXL 1024×768 可跑；1152×864 可能 OOM，必要时降分辨率
- 原生 CUDA 下不再有「一次会话只跑一种架构 / 第二个 SDXL+LoRA 请求必崩」的 ZLUDA 限制；可连续生成
- 实测（2026-10-23，cu130）：Illustrious + `HSR_Style_SDXL` 同一会话连续 5 张全部成功，无崩溃；1024×768 首张 32s（含加载），后续 10–12s/张
- 实测（2026-10-22，cu118）：NoobAI/Illustrious 系 + Illustrious LoRA 无撕裂；同一会话连续 3 个 SDXL+LoRA 请求全部成功；1024×768 首张约 56s（含加载），后续约 15s/张
- Illustrious-XL-v2.0 已安装（`models/checkpoints/Illustrious-XL-v2.0.safetensors`，6.94GB）；推荐参数：**1024×1024 或 1024×768、25 步、dpmpp_2m_sde + karras、CFG 5**（这套脸/手才不扭曲；euler_ancestral/normal 会软且脸手变形）。8GB 下 1152×864 会 OOM；cu130 下连跑 5 个 Illustrious+LoRA 未再出现崩溃，可连续生成
- IP-Adapter（2026-10-23 实测可用）：`models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors` + `models/clip_vision/CLIP-ViT-H-14...`。节点 `IPAdapterUnifiedLoader`（preset `PLUS (high strength)`）+ `IPAdapterAdvanced`（`ipadapter` 接 loader 的**第 2 个输出**）。Illustrious 上 weight 0.3 结构正常、0.5 开始扭曲、0.7 崩坏；`style transfer` 0.5–0.6 较稳。参考图主色调会强污染画面（紫色参考→紫色画面）
- 旧 ZLUDA 遗留：`zluda\` 运行时、本地 ZLUDA 启动器和 `%LOCALAPPDATA%\ZLUDA` 缓存已删除；`patchzluda*.bat`/`testzluda.py` 为仓库跟踪历史文件；ROCm/HIP SDK 已卸载（`C:\Program Files\AMD\ROCm` 不存在，`HIP_PATH` 已清空）
- torch 为官方 cu130 轮子（2026-10-23），未做 ZLUDA DLL 替换

## 常见任务
- 更新项目：`cfz_update_utility.bat`（github 直连被墙，先配置 ghfast.top 镜像：`git -c url."https://ghfast.top/https://github.com/".insteadOf="https://github.com/" pull`）
- 下载模型：国内用 https://hf-mirror.com 替代 huggingface.co
- 旧 ZLUDA 缓存/内核编译说明已失效（`cache-clean.bat` 仅历史）
- 训练 LoRA：`D:\TOOLS\kohya_ss`（anima_train_network.py 等）；ZLUDA 时代的 `zluda.exe -- python` 训练命令在 NVIDIA 上应改为直接 `venv\Scripts\python.exe`

## 目录速览
- `venv\` Python 虚拟环境（对应 D:\Python311）
- `zluda\` ZLUDA 运行时（历史）
- `custom_nodes\` ComfyUI-Manager、CFZ、Impact、IPAdapter、controlnet_aux 等
- `models\checkpoints\`：Illustrious-XL-v2.0、NoobAI-XL-v1.1、animagine-xl-4.0、sd_xl_base_1.0
- `models\diffusion_models\anima_aestheticV11.safetensors`（Anima）
- `models\loras\`：HSR 风格、nsfw_style_v1、三个 Civitai Illustrious、Anima 的 Archinoer/真实细节等

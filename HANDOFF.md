# 交接（2026-10-26）

> 旧版环境交接已归档为 `HANDOFF_2026-10-23.md`。本文件覆盖：当前出图管线（WAI + HSR）、角色 LoRA（Anima 旧线）、12 个概念 LoRA、数据集、训练/验收命令、已知限制。

## 0. 快速恢复

**当前主力（2026-10-25 起）**
- 底模 + 画风：**WAI v17 + `HSR_Style_SDXL` 0.4**，euler_ancestral / 28 步 / CFG 6。**默认 1024×1024**，有要求才用其他尺寸。
- 总控工作流：`user/default/workflows/WAI_HSR04_总控.json`（一图五分支：基础 / OpenPose / Depth / IP-Adapter / 超分）。
- 画风预设：`output/画风预设_WAI_HSR04.md`；使用说明：`output/总控工作流_使用说明.md`。
- 概念 LoRA（12 个）：见 2.5；推荐权重动作 0.7、构图/姿势 0.6、表情 0.5–0.6。
- 完整矩阵报告：`output/完整矩阵训练报告_2026-10-26.md`；Tier 1 验收：`output/Tier1验收_2026-10-25.md`。

**旧主力（Anima，角色 LoRA 仍可用）**
- Anima (`anima_aestheticV11`) + 角色 LoRA 0.8，24 步、euler + simple、CFG 4.5。
- Animagine XL 4.0 + `HSR_Style_SDXL` 0.5（旧测试最佳），28 步、euler_ancestral + normal、CFG 6。
- 角色稳定性报告：`output/稳定性测试报告.md`。
- 角色训练产物：`D:\TOOLS\kohya_ss\output_char\`；ComfyUI 副本 `models/loras/`。
- 记忆：`C:\Users\Chiang\.claude\projects\d--TOOLS-ComfyUI\memory\`。

## 1. 环境

- GPU：RTX 3070 Ti 8GB，原生 CUDA；torch 2.11.0+cu130；ComfyUI 0.42.0。
- 启动：`后台启动ComfyUI.vbs`（无窗口）或 `comfyui-nvidia.bat`；停止：`停止ComfyUI.bat`。
- 8GB 显存：1024×1024 / 896×1152 / 832×1216 稳定；1152×864 可能 OOM。
- 训练：`D:\TOOLS\kohya_ss`，`anima_train_network.py`；停止 `stop_training.bat`。

## 2. 当前 LoRA（`models/loras` 共 26 个，2026-10-27 清理后）

> 完整清单（基座/数据量/触发词/权重/用途）：`output/LoRA清单_2026-10-27.md`

**本地角色**
- `char_aria_v2.safetensors`：Aria 当前主力（成年、140cm、膝上裙）
- `char_aria_v1.safetensors`：Aria 旧版（长发裙、幼态，保留）
- `char_tuoliya_v3.safetensors`：Tuoliya 当前主力（直发字幕重训）
- `char_tuoliya_v2.safetensors`、`char_tuoliya_v1.safetensors`：旧版保留
- `char_ailiya_v1.safetensors`：Aria 旧命名版本（保留，可删）

**下载**
- `D_WEI_ANI_v1-000009`：接近基线，无角色污染
- `civitai_realdetails_anima`：细节增强，角色稳定
- `HSR_Style_SDXL`、`HSR_Style_Pixiv_SDXL`：SDXL HSR 画风
- `civitai_aha_illustrious`、`civitai_alex_illustrious`、`civitai_yaoguang_illustrious`：Illustrious/SDXL，未和角色 LoRA 联测

**已删除**
- 本地非角色：`char_aiselin_v1`、`nsfw_style_v1`、`noobai_nsfw_style_test`、HSR/Genshin 风格 v2/v3/epoch 等
- 2026-10-27 清理：`char_ailiya_v1`、`char_tuoliya_v1`（12 图试验）、`action_pilot`、`style_watercolor_ostris`（SD1.5）、3 个 ntc-ai 风格滑块（共 464 MB）
- 待确认 4 个：`hsr_style_v1`、`Detail hair`、`animaNai5`、`sekali_p`
- 测试不理想：`civitai_archinoer_anima`
- 不兼容：`krea2_auroraNostalgia`（Krea2 架构）
- 回收站已永久清空：17 个文件，3.91 GB。

## 2.5 概念 LoRA（12 个，2026-10-26）

全部在 `models/loras/`，dim 32 / alpha 16，训练基座 WAI v17，768 分辨率。每个 163MB。

| 文件 | 触发词 | 推荐权重 | 适用 / 备注 |
|---|---|---:|---|
| `tier1_action_pair_v1` | act_missionary / act_allfours / act_bentover / act_ontop / act_lyingpair / act_standsex / act_frombehind | 0.7 | 双人硬动作；5/7 有效，bentover/lyingpair 偏弱 |
| `tier1_soft_solo_expr_v1` | expr_openmouth / expr_closedmouth / expr_partedlips / expr_smile / expr_blush | 0.5–0.6 | 软单人表情；偏风格微调 |
| `tier2_hard_pair_comp_v1` | comp_cowboy / comp_full / comp_upper / comp_portrait / comp_closeup | 0.6 | 双人构图；底模本身也听得懂这些词 |
| `tier2_hard_pair_expr_v1` | expr_openmouth / expr_blush / expr_tongueout / expr_smile / expr_ahegao / expr_trembling | 0.6 | 双人表情；tongueout/trembling 无效 |
| `tier2_soft_solo_comp_v1` | comp_cowboy / comp_full / comp_upper / comp_portrait | 0.6 | 软单人构图 |
| `tier2_soft_solo_pose_v1` | pose_sit / pose_stand | 0.6 | 软单人坐/站 |
| `tier3_hard_solo_comp_v1` | comp_cowboy / comp_full / comp_upper / comp_portrait | 0.6 | 硬单人构图 |
| `tier3_hard_solo_expr_v1` | expr_ahegao / expr_tongueout / expr_openmouth / expr_blush / expr_trembling | 0.6 | 硬单人表情；tongueout/trembling 无效 |
| `tier3_hard_solo_pose_v1` | pose_lie / pose_stand / pose_spread | 0.6 | 硬单人躺/站/张腿 |
| `tier3_hard_group_comp_v1` | comp_cowboy / comp_upper / comp_portrait / comp_full | 0.6 | 多人构图 |
| `tier3_hard_group_expr_v1` | expr_smile / expr_openmouth / expr_blush / expr_ahegao / expr_tongueout | 0.6 | 多人表情；tongueout 无效 |
| `tier3_hard_group_action_v1` | act_group / act_gangbang | 0.7 | 多人动作；画面非常直接 |

> 另有 `action_v2.safetensors`（7 触发词、zx1–zx7 别名、1,023 张）。zx token 单独写不出动作，必须配 `missionary` 等概念词；日常仍用 `tier1_action_pair_v1`。

**SDXL / WAI 角色 LoRA（2026-10-26）**
- `char_aria_wai_v1.safetensors`、`char_tuoliya_wai_v1.safetensors`：WAI v17 训练，1200 步 / dim32；可直接进总控、和概念 LoRA 叠加。
- 触发词 `@aria` / `@tuoliya`；**必须配 canonical 外观词**（帽子/服装/发色/瞳色），0.8 权重；只写触发词只能带出部分发色/瞳色。
- 托利亚发型修正（2026-10-26）：**长直发、发尾略卷**。正向用 `(very long straight black hair:1.2), layered, slightly curled ends`，负向加 `wavy hair, curly hair, ringlets, big curls, frizzy hair, green hair`；旧的 `curled ends` 会出明显卷发和绿色发梢。
- 艾莉娅体型修正（2026-10-26）：**娇小、纤细、平胸**。正向加 `(petite adult:1.2), short stature, (small body:1.1), (flat chest:1.1), small breasts, slim, youthful adult face`；负向加 `tall, large breasts, huge breasts, wide hips, thick thighs, mature female, voluptuous, curvy`。旧的写法会出成熟身材。
- 艾莉娅脸型/表情修正（2026-10-26）：**小圆脸 + 三无**。正向加 `(small face:1.1), round face, youthful adult face, delicate features, (expressionless:1.2), blank stare, deadpan, calm, serious, closed mouth`；负向加 `smile, grinning, laughing, happy, cheerful, open mouth, blush, excited`。三无表情在裸体/动作场景里也会显得偏冷，需要时去掉 expressionless。
- 艾莉娅比例修正（2026-10-26）：要**短小骨架**，不是把修长身材缩小。正向加 `(short stature:1.2), (short legs:1.3), (short arms:1.1), compact body, small frame`；负向加 `long legs, long arms, long limbs, slender, tall, elongated proportions, model proportions, supermodel`。
- 艾莉娅内衣偏好（2026-10-26）：**可爱风**。正向 `cute lingerie, pastel pink frilled bra, frilled panties, ribbon, bow, cotton, heart pattern`；负向 `black lingerie, dark lingerie, lace, seductive, sexy`。
- 换装/换姿势实测（2026-10-26）：canonical / 休闲 / 泳装 / 晚礼服 / 内衣 × 站 / 坐 / 躺 / 四肢着地 / 走，身份保持、服装不锁死；姿势结构稳定。
- 总控节点 2（角色槽）默认已改为 `char_aria_wai_v1`、0.8，仍保持绕过；用时取消绕过即可。
- Anima 版 `char_aria_v2` / `char_tuoliya_v3` 仍然保留，只能用于 Anima 管线，不能和 SDXL 概念 LoRA 混用。

**在 ComfyUI 里怎么用**

1. 加载总控工作流（或任意 WAI+HSR 工作流），在 HSR 风格 LoRA 后面串一个 `LoraLoader` 接概念 LoRA；不用时把强度设 0 或绕过。
2. 触发词写在正向提示词最前面，后面接人数/场景 tag，再接画风块。
3. **同一时间只开一个概念 LoRA**；不同轴（动作+构图）不要叠加。
4. 双人/多人触发词要配 `1girl, 1boy, hetero` 或 `1girl, multiple boys`；软色情配 `1girl, solo`。
5. 示例：
   - 双人动作：`act_missionary, missionary, 1girl, 1boy, hetero, indoors` + `tier1_action_pair_v1` 0.7
   - 软单人构图：`comp_upper, upper body, 1girl, solo, simple background` + `tier2_soft_solo_comp_v1` 0.6
6. **百合 / 单方下体场景（2026-10-26 实测）**：
   - 双人动作 LoRA 可以直接配 `2girls, yuri`，5 个强动作都不出男性；两个不同发色/服装可稳定分出两名女性。
   - 要“只有一方下体可见、另一方用手/玩具”：`2girls, yuri, 1girl lying on back, spread legs, spread pussy, another girl behind, upper body, from behind, fingering`（玩具再加 `holding dildo, sex toy, using vibrator`），负向加 `1boy, male, penis, futanari, male focus`，权重 0–0.6。
   - POV 写法容易变成自慰；想要明确双人感用 behind 版。
   - 实测图已于 2026-10-27 清理；说明与结论：`output/百合动作测试_2026-10-26.md`。
7. **角色参考 + 动作 LoRA（2026-10-26 实测）**：
   - **注意**：`char_aria_v2`、`char_tuoliya_v3` 是 Anima 架构（`networks.lora_anima`），不能和 SDXL 概念 LoRA 叠加。SDXL 下用 IP-Adapter 做角色参考。
   - 推荐：IP-Adapter PLUS (high strength)，权重 **0.35**，`V only`；参考图 `char_init/adult_full.png`（Aria）/ `input/角色/tuoliya.png`（Tuoliya）；动作 LoRA 0.7。
   - 0.35：角色发色/服装能带进来，动作还能读；0.5：角色更强但动作变弱（男性常被穿衣），Aria 还会冒出参考图没有的大帽子。
   - 要真正的“角色 LoRA + 概念 LoRA”，需先训 SDXL 版角色 LoRA（Aria 120 图 / Tuoliya 119 图，各约 20–25 分钟）。
   - 说明：`output/IPAdapter角色叠测_2026-10-26.md`。

**验收**

- `output/scripts/eval_tier1.py`、`eval_tier2.py`、`eval_tier3.py`；对比表（`tier*_eval/`）已于 2026-10-27 清理，结论见下面的报告。
- 报告：`output/完整矩阵训练报告_2026-10-26.md`。

## 3. 数据集

### Aria v4（成年版）
- 训练集：`D:\TOOLS\kohya_ss\dataset_char_aria_v4\1_aria`，**120 图 + 120 字幕**
- 浏览图：`D:\TOOLS\ComfyUI\output\training\aria_ds_v4`，复查表：`output\training\aria_review\`
- 设定：成年、142cm 左右、娇小纤细；细碎刘海；膝上深紫裙 + 黑短靴；帽子只在 9/40 姿势出现
- 生成脚本：`output\scripts\aria_ds_120_v4f.py`
- 字幕脚本：`output\scripts\make_aria_v4_captions.py`
- 触发词：`@aria`

### Tuoliya
- 训练集：`D:\TOOLS\kohya_ss\dataset_char_tuoliya\1_tuoliya`，**119 图 + 119 字幕**
- 浏览图：`D:\TOOLS\ComfyUI\output\training\tuoliya_ds`
- 字幕已把 `wavy` 改为 `straight layered ... curled ends`；触发词 `@tuoliya`
- 生成脚本：`output\scripts\tuoliya_ds_120_v2.py`；字幕脚本：`output\scripts\make_char_captions.py`

## 4. 训练

| 项 | Aria v2 | Tuoliya v3 |
|---|---|---|
| 基座 | `anima_aestheticV11` | 同左 |
| 步数 | 10 epoch / 1200 步 | 10 epoch / 1190 步 |
| 输出 | `output_char\char_aria_v2.safetensors` | `output_char\char_tuoliya_v3.safetensors` |
| 日志 | `logs\train_char_aria_v2.log` | `logs\train_char_tuoliya_v3.log` |
| 脚本 | `train_aria_v2.bat` | `train_tuoliya_v3.bat` |

共同参数：dim 32 / alpha 16、`include_patterns=['.*adaln_modulation.*']`、1e-4、cosine_with_restarts、AdamW、fp16、cache latents、gradient checkpointing、unet-only、seed 42、每 epoch 存 LoRA + state。

### 关键修复：字幕扩展名

kohya 的 `--caption_extension` 默认是 `.caption`，我们的字幕是 `.txt`。**之前 v1/v2 训练实际没读字幕**，日志会刷 `No caption file found`。新脚本已加：

```
--caption_extension ".txt"
```

Aria 120 条、Tuoliya 119 条字幕已确认被读取。以后所有训练脚本都要带这个参数。

## 5. 测试结果

### 5.1 稳定性测试（186 张，0 失败）
- 位置：`output\training\stability_final\{aria,tuoliya}\`，分类表 `sheet_*.png`
- 报告：`output\稳定性测试报告.md`
- 覆盖：5 底模、10 服装、10 姿势、6 效果、强度（LoRA/HSR/CFG）、构图、画幅、16 种风格、跨底模风格

**底模结论**
| 底模 | Aria | Tuoliya | 备注 |
|---|---|---|---|
| Anima + 角色 LoRA | ★★★★★ | ★★★★★ | 主力，角色最稳 |
| Animagine + HSR 0.5 | ★★★★☆ | ★★★★☆ | SDXL 最佳平衡 |
| NoobAI + HSR 0.4 | ★★★☆☆ | ★★★☆☆ | 偏半写实、偶发 logo |
| Illustrious + HSR 0.5 | ★★☆☆☆ | ★★★☆☆ | **Aria 银发变蓝**，不要用 |
| SDXL base + HSR 0.7 | ★★★☆☆ | ★★☆☆☆ | 半写实、颜色漂移 |

**参数**
- 角色 LoRA：0.8 默认；1.0 更强；0.6 更松。
- HSR 风格：0.3–0.5；0.7 装饰过载、角色漂移、Tuoliya 兜帽更容易戴上。
- CFG：6 推荐。

### 5.2 NSFW LoRA 画风/人体影响（42 张，全程穿着）
- 位置：`output\training\nsfw_style_influence\`，对比表 `sheet_{aria,tuoliya}_{canonical,wetsuit}.png`
- Aria 权重 0.1/0.2/0.3，Tuoliya 0.2/0.4/0.6。
- 结论：NSFW LoRA 主要带来更柔的明暗和轻微体型强调；衣服负面约束生效，没有裸露画面。角色身份在 Anima 下稳定；SDXL 仍是原有漂移规律。

### 5.3 下载 LoRA 联测（6 张）
- 位置：`output\tests\downloaded_lora_test\sheet_downloaded_lora.png`
- `D_WEI`：接近基线，保留
- `civitai_realdetails_anima`：细节更好，保留
- `civitai_archinoer_anima`：角色漂移明显，已删除

### 5.4 已知问题
- 姿势控制弱：抱臂、躺姿不跟随 → 需要 ControlNet / OpenPose。
- 构图控制弱：俯视、仰视、过肩、三分法区分度低。
- `studio` 纯色背景不纯，仍会带花田/图书馆。
- Tuoliya 在 SDXL 下容易把兜帽戴上；正向写 `hood down, hood resting on shoulders`。
- 异色瞳在 SDXL 下左右/色相不稳；Anima 较好。
- NoobAI 偶发 `STAR RAIL` logo。
- Aria 不能用 Illustrious（银发变蓝）。

### 5.5 概念 LoRA（2026-10-26，12 个）

- **底模很强**：构图（cowboy/full/upper/portrait）、常见表情（open mouth/smile/blush/ahegao）、姿势（sit/stand/lie/spread）用自然 tag 就能出；概念 LoRA 主要增加暴露度/光泽/体型，控制力增量有限。
- **真正有价值**：双人动作（missionary/allfours/ontop/standsex/frombehind）、群体动作（group/gangbang）。
- **失效触发词**：`expr_tongueout`、`expr_trembling`（所有数据集都不出效果）。
- **偏弱**：`act_bentover`、`act_lyingpair`。
- **触发词方法问题**：触发词里含原词（`expr_openmouth` → `open mouth`），CLIP 会拆词，w=0 基线也能出效果；要独立触发词请用无意义 token。
- **外观偏置**：不写发色默认偏粉；硬色情数据偏裸体/油亮/近景；黑发+红眼常有红色发梢。显式角色 prompt 可覆盖（13 组防泄漏全部通过）。
- **19 个常规动作实测（2026-10-26）**：足交、口交、69、手交、授乳手交、乳交、种付、后入压身、面坐、背身坐、站立、后入、抱后、正面抱起、正面/背面骑乘等 **17/19 用自然 tag 就能出**，不需要概念 LoRA。只有 `train bento` 和 `suspended behind` 需要改写：前者会被画成电车场景但悬空不清楚，后者容易变成抱起/拥抱。完整表：`output/19动作测试_2026-10-26.md`。
- **动作 v2 / token 试验（2026-10-26）**：v2（`action_v2.safetensors`，1,023 张、7 个触发词）验收 5/7 成立，bentover 仍弱、侧躺轻微；`zx1–zx7` 只是别名，**单独写 token 不出动作**，必须跟 `missionary` 等概念词一起用。试点证明 UNet-only 学不了无意义 token（CLIP 冻结），token 方案放弃；日常继续用 `tier1_action_pair_v1`。
- **ControlNet 对照（2026-10-26）**：画幅（full/upper/portrait）用自然 tag 最稳；概念 LoRA 0.6 画幅基本对、增加光泽；**Depth 0.75 不控制画幅**（三组都变全身），Depth/OpenPose 控制的是 3D 结构/姿势，不是裁剪。决策表见 `output/高优先级执行记录_2026-10-26.md`。
- **水彩线姿势测试（2026-10-27，14 姿势成对）**：混合线正面光下**底模 14/14 姿势成立**，姿势 LoRA 没有修好任何姿势，反而增加暴露度、把 `kneel` 变成坐椅子、`run` 腿拉超长。建议水彩单人姿势不开姿势 LoRA；要身体强调再降到 0.4–0.5。报告：`output/水彩姿势测试_2026-10-27.md`。
- **水彩奇幻 NSFW 动作（2026-10-27，12 动作 ×3 + 69）**：混合线正面光 + 城堡场景块下 12 动作全部成立（standing 2/3 偏弱），奇幻氛围 36/36 一致；69 用 Depth 0.75，现代卧室参考图没有把奇幻背景带偏。负向要加 `modern, contemporary, modern bedroom, office, city`。报告：`output/水彩奇幻NSFW动作_2026-10-27.md`；场景块已写入混合线工作流 Note。
- **水彩单人全裸姿势（2026-10-27，12 姿势 ×3）**：36/36 成立、服装压干净（负向 `clothes/dress/underwear…` + `1boy, male, hetero`）。遗留：异色瞳丢失、体型偏丰满（要修长加 `slender, small breasts` 并压 `large breasts/huge breasts/thick thighs`）、私处结构简化。报告：`output/水彩单人全裸姿势_2026-10-27.md`；约束块已写入混合线工作流 Note。

## 6. 清理与文件地图

- 临时脚本已删除，19 个关键脚本备份到 `output\scripts\`。
- 临时 ComfyUI 日志 10 个已删除。
- 中间测试目录 24 个（435.6 MB）和进度日志 24 个已删除。
- **2026-10-27 整理**：删除 pycache、旧日志、cn69 骨架/关键点中间产物、`input/cn69` 多余自举图、风格测试下载缓存；**33 个历史测试目录整体删除**（旧风格探索、概念 LoRA 验收、百合/男性/双人测试，含 sheet，共 923 MB 单张 + 107 MB 目录）；删除 7 个 LoRA（464 MB）。`output` 从 3.2 GB 降到 2.2 GB，`models/loras` 从 33 个降到 26 个。历史报告已标注「测试图已清理」。
- LoRA 完整清单：`output\LoRA清单_2026-10-27.md`
- 保留的目录：
  - `output\training\aria_ds_v4`（120 图）
  - `output\training\tuoliya_ds`（119 图）
  - `output\training\aria_review`（数据集复查表）
  - `output\training\stability_final`（186 张 + 分类表）
  - `output\training\nsfw_style_influence`（42 张 + 表）
  - `output\tests\downloaded_lora_test`（6 张 + 表）
  - `output\characters\aria`、`output\characters\tuoliya`、`output\characters\refsheet`、`output\tests\style`（参考图）
  - `output\tests\classify_test`（更早的分类测试产物）
- **2026-10-27 目录分组**：`output/` 顶层只剩 `docs / scripts / watercolor / characters / training / tests`；结构说明见 `output/docs/README.md`。所有 md 文档移入 `output/docs/`，路径引用与脚本 SaveImage 前缀已同步改写。
- 文档（2026-10-27 核对，旧报告已不存在）：
  - 当前状态：`output\交接_2026-10-26_新对话启动.md`、`output\LoRA清单_2026-10-27.md`
  - 技术结论：`output\69_ControlNet_2026-10-26.md`、`output\IPAdapter角色叠测_2026-10-26.md`、`output\男性透明_阴茎测试_2026-10-26.md`
  - 水彩线：`output\水彩电影感_2026-10-26.md`、`output\水彩双线_2026-10-27.md`、`output\水彩混合线_2026-10-27.md`、`output\水彩姿势测试_2026-10-27.md`、`output\水彩奇幻NSFW动作_2026-10-27.md`、`output\水彩单人全裸姿势_2026-10-27.md`
  - 历史记录：`output\19动作测试_2026-10-26.md`、`output\完整矩阵训练报告_2026-10-26.md`、`output\高优先级执行记录_2026-10-26.md`、`output\未解决问题清单_2026-10-26.md`、`output\百合动作测试_2026-10-26.md`
  - 规划/参考：`output\三风格管线与训练计划_2026-10-26.md`、`output\高画面日本动画画风参考.md`

## 7. 下一步 / 待办

1. 需要精确姿势/构图时接 ControlNet（OpenPose / 深度 / 线稿），当前纯提示词控制弱。
2. 剩余 5 个 SDXL 下载 LoRA（`HSR_Style_SDXL`、`HSR_Style_Pixiv_SDXL`、三个 `civitai_*_illustrious`）尚未和角色联测；要测就用 Illustrious/Animagine/NoobAI 管线，不理想的继续删。
3. 如果以后需要 Aiselin（艾瑟琳）LoRA：`char_aiselin_v1` 已删除，需要重训；记得加 `--caption_extension ".txt"`。
4. ~~`char_ailiya_v1` 是 Aria 旧命名旧版~~ **2026-10-27 已删除**（连同 12 图试验版 `char_tuoliya_v1`）。
5. Tuoliya v3 已用直发字幕重训；如果出图仍偏波浪，先加负面 `wavy hair, curly hair`，不行再考虑局部重跑数据集。
6. 如果 Aria 还要更成熟或更高，重新生成数据集并重训；不要只改字幕，年龄/身高是视觉属性。
7. ComfyUI 的 LoRA 列表在删除/新增文件后要重启才刷新。

## 8. 复现命令

```bat
:: 启动 ComfyUI
D:\TOOLS\ComfyUI\comfyui-nvidia.bat

:: 停止
D:\TOOLS\ComfyUI\停止ComfyUI.bat

:: 训练（示例）
D:\TOOLS\kohya_ss\train_aria_v2.bat
D:\TOOLS\kohya_ss\train_tuoliya_v3.bat
D:\TOOLS\kohya_ss\stop_training.bat
```

概念 LoRA（Tier 1–3）构建与训练：

```bat
:: 构建数据集（示例：双人构图）
D:\TOOLS\kohya_ss\venv\Scripts\python.exe D:\TOOLS\kohya_ss\scripts\build_concept_dataset.py ^
  --mode hard_pair_composition --out D:\TOOLS\kohya_ss\dataset_tier2_hard_comp --per-trigger 220

:: 训练（按 Tier 顺序）
D:\TOOLS\kohya_ss\train_tier1_all.bat
D:\TOOLS\kohya_ss\train_tier2_all.bat
D:\TOOLS\kohya_ss\train_tier3_all.bat
D:\TOOLS\kohya_ss\暂停训练.bat
```

- 8GB 安全线：**768 分辨率、max_bucket_reso 1024、dim 32 / alpha 16**；1024 + dim64 会溢出到共享显存，速度从 1.1 秒/步掉到 27 秒/步。
- 训练脚本必须带 `HF_HUB_OFFLINE=1` / `TRANSFORMERS_OFFLINE=1`，否则 tokenizer 加载会去连 huggingface.co 并 SSL 报错。
- 被强杀过的数据集，重跑前删掉 `*.npz`，否则 `BadZipFile`。
- 停 ComfyUI 的 `停止ComfyUI.bat` 已排除 kohya 进程；停训练用 `暂停训练.bat`。

概念 LoRA 验收（先启动 ComfyUI）：

```bat
D:\TOOLS\ComfyUI\venv\Scripts\python.exe output\scripts\eval_tier2.py ^
  --hard-comp tier2_hard_pair_comp_v1.safetensors ^
  --hard-expr tier2_hard_pair_expr_v1.safetensors ^
  --soft-comp tier2_soft_solo_comp_v1.safetensors ^
  --soft-pose tier2_soft_solo_pose_v1.safetensors

D:\TOOLS\ComfyUI\venv\Scripts\python.exe output\scripts\eval_tier3.py ^
  --solo-comp tier3_hard_solo_comp_v1.safetensors ^
  --solo-expr tier3_hard_solo_expr_v1.safetensors ^
  --solo-pose tier3_hard_solo_pose_v1.safetensors ^
  --group-comp tier3_hard_group_comp_v1.safetensors ^
  --group-expr tier3_hard_group_expr_v1.safetensors ^
  --group-action tier3_hard_group_action_v1.safetensors
```

测试脚本（在 ComfyUI 根目录运行，需先启动服务）：

```bat
venv\Scripts\python.exe output\scripts\stability_final_test.py
venv\Scripts\python.exe output\scripts\nsfw_style_influence_test.py
venv\Scripts\python.exe output\scripts\downloaded_lora_test.py
```

## 9. 工程 / 运维（2026-10-26）

### 9.1 ComfyUI 常驻（推荐）
- 启动（无浏览器、隐藏窗口、独立进程，会话关闭不会被杀）：
  `wscript.exe D:\TOOLS\ComfyUI\start_comfyui_service.vbs`
- 控制台输出：`user\comfyui_service.log`
- 停止（无 pause，适合脚本）：`D:\TOOLS\ComfyUI\stop_comfyui_service.bat`
- 带浏览器启动（旧习惯）：`后台启动ComfyUI.vbs`；停止：`停止ComfyUI.bat`

### 9.2 任意 bat 后台运行
- `wscript.exe D:\TOOLS\kohya_ss\run_bat_hidden.vbs "D:\TOOLS\kohya_ss\train_tier3_all.bat"`
- 原理：wscript 立刻退出，bat 是孤儿进程 + 独立隐藏控制台；Claude Code / 终端关闭不影响。
- 已验证：启动命令结束后 bat 仍继续运行。

### 9.3 训练相关
- 启动：`train_tier1_all.bat` / `train_tier2_all.bat` / `train_tier3_all.bat`；建议用 9.2 后台启动。
- 停止：`暂停训练.bat`（= `stop_training.bat`），已排除 ComfyUI 进程。
- 所有训练脚本带 `HF_HUB_OFFLINE=1` / `TRANSFORMERS_OFFLINE=1`；否则 tokenizer 会连 huggingface.co 报 SSL。
- 缓存损坏：被强杀后 `.npz` 会截断，重跑报 `BadZipFile`。先检查：
  `python D:\TOOLS\kohya_ss\clean_cache.py <dataset_dir> --dry`
  去掉 `--dry` 删除损坏项；`--all` 删全部重建。
- 8GB 安全线：768 分辨率、max_bucket 1024、dim 32；1024 + dim64 会溢出共享显存。

### 9.4 保持唤醒
- `wscript.exe D:\TOOLS\kohya_ss\launch_keep_awake.vbs`（隐藏 PowerShell，SetThreadExecutionState，阻止空闲睡眠；进程退出/关机后失效）。

### 9.5 踩过的坑
- **VBS 文件不要写中文注释**：无 BOM 的 UTF-8 中文会让 WSH 解析失败，表现为 wscript 静默退出、bat 不执行。VBS 只用 ASCII 注释。
- ComfyUI 端口 8188 只允许一个实例；重复启动会出现端口占用 + 多个 python，用 `stop_comfyui_service.bat` 清掉再启动。
- DWPose 对部分参考图出黑骨架（如 `char_init/adult_full.png`）；默认用 `adult_upper_left.png`。
- 旧工作流备份在 `output/workflow_backup_2026-10-25/`（9 个），确认无用后再永久删除。

### 9.6 未解决问题清单
- `output/未解决问题清单_2026-10-26.md`

## 10. 风格管线（2026-10-26）

**已有**
- `user/default/workflows/WAI_HSR04_总控.json`：星铁/高饱和线（WAI + HSR 0.4 + 概念槽）。
- `user/default/workflows/Style_Watercolor_水彩.json`：**明亮线**（紫罗兰式，暖金/发光），淡彩明亮版（2026-10-26 早锁定）。
- `user/default/workflows/Style_Watercolor_清冷.json`（2026-10-27 新增）：**清冷线**（芙莉莲式，淡蓝/薄雾/细线），配方 = `cool_pastel`；角色槽 `char_tuoliya_wai_v1` 0.8（默认绕过）。两条线差异是色温，靠负向区分（清冷压 `warm colors, golden light, saturated colors`）。记录：`output/水彩双线_2026-10-27.md`。
- `user/default/workflows/Style_Watercolor_混合.json`（2026-10-27 新增）：**混合线**（暖场景 + 冷人物）。**默认正面光**（`soft front lighting on character` + 负向压 `backlight/rim light/silhouette`），靠 `(warm background lighting), (warm and cool color contrast)` 分离冷暖；要背光黄昏感可换回 `cool blue rim light on character` 并删掉光位负向。负向**不要**写 `saturated/warm colors`。8 场景测试（明亮户外/昏暗户外/城市/森林/海边/草地/河水/沙漠）。记录：`output/水彩混合线_2026-10-27.md`。
- `user/default/workflows/Style_FilmWatercolor_电影水彩.json`（2026-10-26 晚新增）：**动画电影感**——干净线稿 + 平涂渐变 + 淡彩背景；负向已放开 `cel shading/game cg/official art`；角色 LoRA 槽 = `char_aria_wai_v1` 0.8（默认绕过）。记录：`output/水彩电影感_2026-10-26.md`。
- `user/default/workflows/Style_Fantasy_奇幻.json`：丰润奇幻/自然，WAI + 森林/草原/暖光提示词；同样两个 LoRA 槽默认绕过。

**水彩/奇幻测试结论**
- 下载的 4 个 HF 风格 LoRA（ostris watercolor、ntc-ai watercolor/ghibli/fantasy slider，8–12MB）在 WAI 上隔离测试和 1.0 权重下都**基本无效**。
- 目前水彩/奇幻效果主要来自**提示词 tag + 负向**（`watercolor/muted/pastel/soft lighting`；`lush nature/forest/meadow/warm sunlight`；负向压 `vibrant/saturated/glossy/cel shading`）。
- 以后找到 Illustrious 专用或更大的风格 LoRA，再启用工作流里的风格槽（0.6–0.8）。

**采样**
- 水彩/奇幻统一 euler_ancestral / normal / 28 步 / CFG 6；**默认 1024×1024**；人物竖图 832×1216、横向风景 1216×832 按需。
- 电影感线暂缓，等前两条稳定后再做。

## 11. 最新状态（2026-10-26 晚）

**水彩线（已锁定明亮版）**
- 配方：`watercolor, pastel colors, bright colors, luminous, ethereal, golden light, light particles, soft focus, detailed flowers, cinematic lighting, airy, gentle atmosphere, watercolor texture, visible brush strokes`
- 负向：常规质量 + `oversaturated, neon, glossy, harsh contrast, dark, gloomy, cel shading, game cg, official art`；**不要再写 `vibrant colors` / `saturated`**。
- 已更新 `Style_Watercolor_水彩.json` 的默认正向/负向和 Note。
- 测试产物：
  - 明亮 13 张：`output/watercolor/watercolor_bright_batch/`（`sheet_style.png`、`sheet_chars.png`）
  - 12 场景/光线：`output/watercolor/watercolor_scenes/sheet_scenes.png`
  - 12 昏暗场景：`output/watercolor/watercolor_dark/sheet_dark.png`
- 昏暗配方：`watercolor, muted colors, dim lighting, low key lighting, cinematic shadows, moody atmosphere, atmospheric, soft glow, painterly, detailed background`，负向压 `bright, overexposed, high key, daylight`。

**艾莉娅完整配方（锁定）**
- 体型：`(petite adult:1.2), (short stature:1.2), (short legs:1.3), (short arms:1.1), compact body, small frame, (flat chest:1.1), small breasts`
- 脸/表情：`(small face:1.1), round face, youthful adult face, delicate features, (expressionless:1.2), blank stare, deadpan, calm, serious, closed mouth`
- 发色：`very long silver-white hair, light blue hair tips, subtle blue gradient at the ends, blue eyes, adult woman`
- 内衣：`cute lingerie, pastel pink frilled bra, frilled panties, ribbon, bow, cotton, heart pattern`
- 负向：`long legs/arms, slender, tall, elongated proportions, large breasts, wide hips, mature female, voluptuous, curvy, smile, laughing, open mouth, blush, excited, black lingerie, lace, seductive`
- 全套 220 张：`output/characters/aria/01_gallery/aria_full_v3/`（8 张表在 `sheets/`）。

**托利亚配方（锁定）**
- `(very long straight black hair:1.1), slightly curled ends, purple-tinted ends, heterochromia, left eye emerald green, right eye golden yellow, tall, slender, adult woman`
- 负向加 `wavy hair, curly hair, ringlets, big curls, frizzy hair, green hair`。
- 整套：`output/characters/tuoliya/01_gallery/gallery_v2/`（145 张 + 表）。

**当前待办**
1. ~~69 式仍弱~~ **已解决（2026-10-26）**：OpenPose 检测器在交叠裸体上失效；改用 **Depth ControlNet 0.75 + 自举参考图 `input/cn69/boot_69007_00001_.png`**，1216×832，12/12 锁住互相。说明：`output/69_ControlNet_2026-10-26.md`。
2. 水彩/奇幻现成 style LoRA 在 WAI 上基本无效，继续 tag-only；以后找到更强 LoRA 再启用工作流里的风格槽。
3. 电影感线未开始。
4. 明亮/昏暗水彩可挑图放大到 1920/4K。
5. 旧画廊（Aria v3 之前的 145+15+75 张）仍在；需要彻底清理再确认。

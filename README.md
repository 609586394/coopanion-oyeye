# Coopanion Party Patch

给 [Coopanion](https://github.com/Pal-AI-Lab/Coopanion) 的桌宠加一个彩蛋：

> 对它说 **「欧耶耶」** → 播放《朋友的酒》并跟着节拍把整个人压扁弹起；说 **「停停」** → 停下。

![效果](https://img.shields.io/badge/Coopanion-0.2.8-00a870) ![license](https://img.shields.io/badge/license-AGPL--3.0-blue)

---

## 给 agent 的安装指引（人也可以直接照着跑）

把这个仓库链接发给 agent，说：

> 按 README 把这个 party patch 装到 Coopanion，装完重启，确认它说「欧耶耶」有声音、会弹。

agent 需要做的：

1. 拿到仓库（clone 或下载 zip 解压）。
2. 在仓库目录里运行：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Restart
   ```

   脚本会自己找 Coopanion（运行中的进程、`%LOCALAPPDATA%\Programs\Coopanion`、`D:\Coopanion`、`C:\Coopanion`），备份三个文件，打补丁，做 JS 语法检查，然后重启。

3. 音频默认没有（版权原因）。要完整效果，先让使用者提供一个 mp3，再跑：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Audio "D:\music\friends-wine.mp3" -Restart
   ```

   或者从使用者自己给的页面提取：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -SongUrl "https://www.bilibili.com/video/BV..." -Restart
   ```

4. 验收：宠物窗口出现后，在 Coopanion 对话框输入「欧耶耶」——应该开始放歌并压扁弹跳；输入「停停」停下。

5. 失败时把脚本输出原样带回；`-Uninstall` 可从备份还原。

---

## 安装细节

改的是 Coopanion 自带的 desktop-pet World 里的三个文件：

| 文件 | 改动 |
|---|---|
| `resources\app\app\main.cjs` | 允许无手势自动播放（消息来自另一个窗口，宠物页自己没有手势） |
| `resources\app\node_modules\cortico-world-desktop-pet\web\pet-app.js` | 触发词、音频播放、按 `audio.currentTime` 算相位做压扁动画 |
| `...\web\pet.css` | `.figure-layer.party` 的 transform 样式 |

补丁是**锚点替换**：这个版本（Coopanion 0.2.8）的对应代码找不到就安全中止，不会写坏文件。重复运行是幂等的。

备份在 `<Coopanion>\backup-party`，只备份第一次。

## 音频

**仓库不附带任何音频。** 《朋友的酒》是有版权的录音，请自行准备，或用 `-SongUrl` 从你有权使用的来源提取（需要 Python + yt-dlp）。

音频放在 `...\cortico-world-desktop-pet\web\party\friends-wine.mp3`。没有音频时动画照常，只是没声音。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Uninstall -Restart
```

## 已知边界

- 只在 **Coopanion 0.2.8 / Windows** 上验证过；其他版本锚点可能不匹配，脚本会中止并提示。
- Coopanion 升级会覆盖 `resources`，升级后需要重跑一次。
- 节拍按 129.2 BPM（实测这首歌）计算；换别的歌会把 BPM 写死在 `PARTY_BEAT` 里，需要改。
- 压扁是缩放整个 `figure-layer`，所以 origin 跟着身体位置走；如果宠物走到屏幕边缘仍觉得有位移，那是这个实现的固有边界。

## 许可与来源

- 本项目：**AGPL-3.0-or-later**（见 [LICENSE](LICENSE)）。
- 基于 [Coopanion](https://github.com/Pal-AI-Lab/Coopanion)（AGPL-3.0）与 [Cortico](https://github.com/Pal-AI-Lab/Cortico)（MIT）的代码修改，版权归原作者。
- 不含 DeepSeek Whale 美术资源（不在 AGPL 覆盖范围），也不含歌曲音频。
- 详见 [NOTICE](NOTICE)。

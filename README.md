# Coopanion Party Patch

给 [Coopanion](https://github.com/Pal-AI-Lab/Coopanion) 的桌宠加一个彩蛋：

> 对它说 **「欧耶耶」** → 播放《朋友的酒》、跟着节拍把整个人压扁弹起，气泡里同步显示歌词；说 **「停停」** → 停下。

仓库**自带音频**（`assets/friends-wine.mp3`，5.5 MB）和**歌词**（`assets/lyrics.json`，时间轴来自原视频画面里的字幕），安装时自动装好，装完直接有声音有词。想换自己的歌用 `-Audio` 或 `-SongUrl`。

![效果](https://img.shields.io/badge/Coopanion-0.2.8%20%2F%200.2.10-00a870) ![license](https://img.shields.io/badge/license-AGPL--3.0-blue)

---

## 给 agent 的安装指引（人也可以直接照着跑）

把这个仓库链接发给 agent，说：

> 按 README 把这个 party patch 装到 Coopanion，装完重启，确认它说「欧耶耶」有声音、会弹。

agent 需要做的：

**最省事：一行命令，不用 clone**（音频会自动下载）

```powershell
$p="$env:TEMP\coopanion-party.ps1"; irm https://raw.githubusercontent.com/609586394/coopanion-oyeye/main/install.ps1 -OutFile $p; powershell -ExecutionPolicy Bypass -File $p -Restart
```

换自己的音频：

```powershell
$p="$env:TEMP\coopanion-party.ps1"; irm https://raw.githubusercontent.com/609586394/coopanion-oyeye/main/install.ps1 -OutFile $p; powershell -ExecutionPolicy Bypass -File $p -Audio "D:\music\friends-wine.mp3" -Restart
```

**或者** clone / 下载 zip，在仓库目录里：

1. 运行：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Restart
   ```

   脚本会自己找 Coopanion（运行中的进程、`%LOCALAPPDATA%\Programs\Coopanion`、`D:\Coopanion`、`C:\Coopanion`），备份三个文件，打补丁，做 JS 语法检查，然后重启。

2. 音频默认没有（版权原因）。要完整效果，先让使用者提供一个 mp3，再跑：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Audio "D:\music\friends-wine.mp3" -Restart
   ```

   或者从使用者自己给的页面提取：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1 -SongUrl "https://www.bilibili.com/video/BV..." -Restart
   ```

3. 验收：宠物窗口出现后，在 Coopanion 对话框输入「欧耶耶」——应该开始放歌并压扁弹跳；输入「停停」停下。

4. 失败时把脚本输出原样带回；`-Uninstall` 可从备份还原。

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

## 音频与歌词

仓库自带一份 `assets/friends-wine.mp3`（5.5 MB，187 秒），安装时复制到
`...\cortico-world-desktop-pet\web\party\friends-wine.mp3`。

- 想换成自己的歌：`-Audio "D:\music\xxx.mp3"`；
- 想从页面提取：`-SongUrl "https://..."`（需要 Python + yt-dlp）；
- 目标位置已有文件时不会重复下载。

`assets/lyrics.json` 是播放时气泡里显示的歌词：时间轴来自原视频**画面里烧录的字幕**
（按秒抽帧 + OCR 合并），文本经过人工校正。放歌时按 `audio.currentTime` 逐行切换，
停止或播完自动收起。想配自己的歌，把 `lyrics.json` 换成 `[{"t": 秒, "text": "..."}]` 即可。

**音频来源**：B 站视频 [BV1hXbN6VEKV](https://www.bilibili.com/video/BV1hXbN6VEKV/)
（UP 主：**活跃黑江乐**）——《朋友的酒》DJ 完整版。录音版权归原权利人，本仓库仅为个人分享，
如权利人要求会立即删除。**仅供个人学习使用，请勿商用或二次分发。**

**灵感来源**：B 站视频 [BV1TbJ665Ecf](https://www.bilibili.com/video/BV1TbJ665Ecf/)
「【赤石科技/dsh 插件】发送欧耶耶让你的肥鱼开始蹦迪」（UP 主：**非得干点啥**），
原项目 [dsh-disco-whale](https://github.com/learnfrom325/dsh-disco-whale)。
那条视频的灵感来自 BV1kTp962EJG（@幸羽雪雪），角色图来自 dsh-whale-widget（@T7moris）。
本仓库只重写了 Coopanion 这一侧的触发与动画，与上述作者无隶属关系。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Uninstall -Restart
```

## 已知边界

- **版本**：Windows 上验证过 Coopanion **0.2.8 和 0.2.10**；其他版本如果锚点对不上，脚本会中止并提示，不会写坏文件。
- **升级**：Coopanion 升级会覆盖 `resources`，升级后重跑一次 `install.ps1` 即可（幂等，不会重复打补丁）。
- **节拍**：按 129.2 BPM（实测这首歌）写死在 `PARTY_BEAT` 里；换别的歌要一起改，否则压扁对不上鼓点。
- **歌词**：时间轴来自原视频画面字幕的 OCR，重复段落和同音字可能有偏差；换歌要同时换 `assets/lyrics.json`。
- **压扁范围**：缩放的是整个宠物图层（`figure-layer`），不是单张立绘。原点会跟着身体位置走，但在极窄的屏幕边缘仍可能有 1px 级的抖动。
- **音频**：仓库自带的音轨是有版权的录音，仅作个人分享，见上面的「音频与歌词」。

## 许可与来源

- 本项目代码：**AGPL-3.0-or-later**（见 [LICENSE](LICENSE)、[COPYING](COPYING)）。
- 基于 [Coopanion](https://github.com/Pal-AI-Lab/Coopanion)（AGPL-3.0）与 [Cortico](https://github.com/Pal-AI-Lab/Cortico)（MIT）的代码修改，版权归原作者。
- **不含** DeepSeek Whale 美术资源（不在 AGPL 覆盖范围）。
- 音频版权不属于本项目，见上面的「音频来源」。
- 详见 [NOTICE](NOTICE.md)。

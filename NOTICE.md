# NOTICE

Coopanion Party Patch 是一个补丁，不是 Coopanion 的分支或再分发。

## 上游

- **Coopanion** — https://github.com/Pal-AI-Lab/Coopanion — AGPL-3.0-or-later
  - 本补丁修改其中 `resources/app/app/main.cjs` 与
    `resources/app/node_modules/cortico-world-desktop-pet/web/pet-app.js`、
    `web/pet.css` 三个文件（安装时由 `install.ps1` 在目标机器上完成）。
- **Cortico** — https://github.com/Pal-AI-Lab/Cortico — MIT
  - Coopanion 的框架，本补丁未直接修改其源码。

原始版权与许可声明归原作者所有。本补丁按 AGPL-3.0-or-later 发布（见 LICENSE 与 COPYING）。

## 不包含的内容

- **歌曲音频**：《朋友的酒》的录音版权不属于本项目，仓库不附带任何音频。
  使用者需自行准备，或用 `-SongUrl` 从自己有权使用的来源提取。
- **DeepSeek Whale 美术资源**：Coopanion 的 `packages/cortico-world-desktop-pet/web/whale/`
  下的贴图不在 AGPL 覆盖范围，本仓库不包含、也不再分发它们。
- **Coopanion 本体**：本仓库只有补丁脚本与说明，不打包 Coopanion。

## 商标

DeepSeek、Bilibili 等名称与标识属于其各自所有者，仅用于说明用途。

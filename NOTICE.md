# NOTICE

Coopanion Party Patch 是一个补丁，不是 Coopanion 的分支或再分发。

## 上游

- **Coopanion** — https://github.com/Pal-AI-Lab/Coopanion — AGPL-3.0-or-later
  - 本补丁修改其中 `resources/app/app/main.cjs` 与
    `resources/app/node_modules/cortico-world-desktop-pet/web/pet-app.js`、
    `web/pet.css` 三个文件（安装时由 `install.ps1` 在目标机器上完成）。
- **Cortico** — https://github.com/Pal-AI-Lab/Cortico — MIT
  - Coopanion 的框架，本补丁未直接修改其源码。

原始版权与许可声明归原作者所有。本补丁代码按 AGPL-3.0-or-later 发布
（见 LICENSE 与 COPYING）。

## 音频

`assets/friends-wine.mp3` 是《朋友的酒》DJ 完整版，来源：
B 站视频 **BV1hXbN6VEKV**（UP 主：**活跃黑江乐**）。

录音版权归原权利人所有，**不在本项目的 AGPL 许可范围内**。本仓库包含它仅为
个人分享与学习用途；如权利人要求，会立即删除。请勿商用或二次分发。

## 灵感与致谢

- B 站视频 **BV1TbJ665Ecf**「【赤石科技/dsh 插件】发送欧耶耶让你的肥鱼开始蹦迪」
  （UP 主：**非得干点啥**），原项目
  [dsh-disco-whale](https://github.com/learnfrom325/dsh-disco-whale)。
- 该视频的灵感来自 **BV1kTp962EJG**（@幸羽雪雪）。
- 角色图来自 **dsh-whale-widget**（@T7moris）。

本仓库只重写了 Coopanion 这一侧的触发与动画，与上述作者无隶属关系。

## 不包含的内容

- **DeepSeek Whale 美术资源**：Coopanion 的
  `packages/cortico-world-desktop-pet/web/whale/` 下的贴图不在 AGPL 覆盖范围，
  本仓库不包含、也不再分发它们。
- **Coopanion 本体**：本仓库只有补丁脚本、说明和一份音频，不打包 Coopanion。

## 商标

DeepSeek、Bilibili 等名称与标识属于其各自所有者，仅用于说明用途。

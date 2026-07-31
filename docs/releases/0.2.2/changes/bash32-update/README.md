---
business: bash32-update
version: 0.2.2
release_tag: 0.2.2
release_owner_type: project
release_owner_id: Team-Intelligence-Center
release_registry_root: docs/releases
date: 2026-07-27
---

# Bash 3.2 一键更新兼容修复

## 发版概览

- mode：`single`
- tag 类型：`hotfix`
- tag 仓库：Team-Intelligence-Center
- tag 来源：`hotfix/0.2.2`
- tag 目标：`0a55134555d25eab38220961db9f251375ef606c`
- 远端状态：`origin` 已 push
- 部署触发：tag push 后进入 stable 更新通道
- 发布对象：Shell 一键更新器、版本元数据、回归和发布文档
- 不发布对象：PowerShell 逻辑、业务代码、数据库、生产配置

## 使用说明

0.2.1 用户第一次升级到 0.2.2 时，需要让旧脚本的可选数组非空：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project \
  --codex-home /path/to/.codex
```

升级到 0.2.2 后，普通使用者继续执行：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project
```

不再需要为规避 Bash 3.2 缺陷而显式传入 `--codex-home`。

## QA 冒烟

- 默认 preview 不报 `unbound variable`。
- 默认 apply 能调用全局 Loader 安装器。
- 显式 `--codex-home` 保持原值。
- stable 通道选择 `0.2.2`。
- 项目 lock 更新为 `0.2.2`。
- 已有 Project Adapter 校验和不变。

## 监控与回滚

- 观察更新输出中的 stable tag、active rules version、全局 Loader 和项目刷新结果。
- 回滚到 `0.2.1` 时，必须显式传入 `--codex-home` 或跳过全局刷新。
- 无数据库、数据迁移或不可逆步骤。

## 发布结果

- tag 与 `origin/master` 指向 `0a55134555d25eab38220961db9f251375ef606c`。
- develop 回灌提交为 `7946224a322676f0634f9770f622399974ff952a`。
- 父项目和 8 个子项目 lock 均为 `0.2.2`。
- 9 个既有 adapter 校验和不变，全局 Loader 为 `0.2.2`。

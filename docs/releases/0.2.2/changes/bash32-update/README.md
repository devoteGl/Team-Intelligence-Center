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
- tag 目标：合入 `master` 后的发布提交，发布后回填
- 远端状态：发布后回填
- 部署触发：tag push 后进入 stable 更新通道
- 发布对象：Shell 一键更新器、版本元数据、回归和发布文档
- 不发布对象：PowerShell 逻辑、业务代码、数据库、生产配置

## 使用说明

发布后普通使用者继续执行：

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

## 待发布后回填

- tag 目标 commit 与远端 tag。
- `origin/master`、`origin/develop` 和回灌证据。
- 父子项目 lock、adapter 校验和与全局 Loader 版本。

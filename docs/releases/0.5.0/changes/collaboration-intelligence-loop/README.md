---
business: collaboration-intelligence-loop
version: 0.5.0
release_tag: pending
release_owner_type: project
release_owner_id: Team-Intelligence-Center
release_registry_root: docs/releases
date: 2026-08-07
---

# 协作复利闭环交接

## 交付对象

- canonical 协作记忆 Skill 与 Codex wrapper。
- 共享 memory、本地画像和候选队列模板。
- Orchestrator、Project Adapter、bootstrap、全局/项目规则和使用说明。
- 首次创建、普通 refresh 保留、gitignore、wrapper 与路由回归。

## 使用路径

1. 用户明确要求协作记忆，或候选经验被确认具有长期价值时启用 Capability。
2. 显式检索只注入 3～7 条直接相关、已确认、未过期的记忆。
3. 发现当前证据、规格或用户指令冲突时执行 `mode=reconcile`。
4. 显式提取以 `mode=extract` 生成 0～5 条候选。
5. 个人偏好只写 `.tic/local/`；团队/项目资产经确认后写
   `ai-harness/memory/`。

## 安全与回滚

- 不保存原始聊天、秘密、认证状态、PII 或未脱敏生产数据。
- 跨任务分析历史必须获得用户明确授权。
- 升级只新增缺失的共享模板，已有 memory 逐字节保留。
- 如需回退规则行为，可使用显式 ref `0.3.0`；已创建的 memory 文件可保留，
  旧版本会将其视为未知项目资产。
- 无数据库、生产配置、远端写入或不可逆迁移。

## 状态

- 本地开发、隔离验证和 8 个正式父子项目试运行已完成。
- PowerShell runtime 为 `partial`，验证器在无 `pwsh` 时显式 warning。
- `0.5.0` tag 尚未创建。
- 按用户要求不 push。

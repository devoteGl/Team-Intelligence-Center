# TIC 0.5.3 交付走查

## 用户会看到什么变化

- Git 写操作使用统一分支、中文 scoped commit、权威远端和回灌边界；
- 普通修复仍直接执行，不会被强制要求 PRD。
- 新产品或重大用户旅程没有产品基线时，Agent 先形成可确认 PRD 草稿。
- 用户可见产品在持久实现前明确角色、主旅程、信息架构和关键状态。
- 已确认产品基线后，本地实现继续自主推进，不把 PRD 确认变成每步审批。
- 开发完成后只有预先批准的行为可以同步到 PRD；意外偏移会被标为规格漂移。

## 三个入口

| Wrapper | 使用时机 | 结果 |
| --- | --- | --- |
| `tic-prd-author` | 创建 PRD 或缺少产品基线 | DRAFT 产品基线或 PRD |
| `tic-prd-review` | 审查已有 PRD | 就绪 verdict、阻断项和破坏性风险 |
| `tic-post-dev-prd-sync` | 同步已批准交付 | PRD 更新草案或规格漂移报告 |

## 如何检查

1. 查看 `Workflow/scenarios.json` 的四个新增行为场景。
2. 用全局安装器的临时 Codex Home fixture 检查三个 wrapper。
3. 核对 PRD 生成参考不再要求固定八章和自动 FE/BE 拆分。
4. 运行 `bash tools/validate-pack.sh`，确认旧 Capability 和安装回归无退化。
5. 用分支/提交校验器正反例核对 Git 策略，并确认已知旧 Skill 迁移有备份。

## 不包含什么

- 不恢复默认 Orchestrator；
- 不要求所有改动创建 PRD、OpenSpec 或视觉稿；
- 不移除 0.6.0 计划处理的兼容 alias；
- 不自动批准 PRD、实现、Git、迁移或发布。

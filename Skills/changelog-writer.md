---
schema: tic_capability.v1
id: changelog-writer
status: canonical
category: persistence
activation:
  when:
    - 发布者或用户需要面向消费者的持久变更记录
    - 项目政策要求维护 changelog 或 release notes
  not_when:
    - 普通实现摘要已满足当前消费者
    - 只因代码发生变化或准备提交
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 项目既有 changelog、release notes 或发布登记
requires: []
related:
  - release-handoff
  - post-dev-prd-sync
---
- 是否创建独立 release notes、PRD 更新或走查，由各自产物消费者分别决定。
- 是否创建独立 release notes、PRD 更新或走查，由各自产物消费者分别决定。
# Changelog Writer（变更记录能力）

## 技能用途

把已验证的变化翻译为目标读者能使用的 release notes 或 changelog。目标文件
和格式服从项目既有政策；不强制写入 `PRD/` 或同时维护两套日志。

## 方法

1. 确认读者、版本/时间范围、事实源和目标位置。
2. 从 diff、提交、issue、验证证据和已确认决定中提取变化。
3. 按消费者关心的行为组织，区分新增、修复、变化、弃用、迁移和已知问题。
4. 明确 breaking change、升级动作与兼容范围；没有证据的内容不写。
5. 去重并核对版本、链接、命令和状态，再更新项目既有文件。

```markdown
## <version-or-date>

### Changed
- <用户或运维可感知的变化>（证据：...）

### Migration
- <仅在需要时>
```

- 内部重构只有在影响消费者、风险或迁移时才出现。
- 不把提交标题机械复制为产品说明。
- 是否创建独立 release notes、PRD 更新或走查，由各自产物消费者分别决定。

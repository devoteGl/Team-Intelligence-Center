---
schema: tic_capability.v1
id: release-ops-handoff
status: alias
category: compatibility
activation:
  when:
    - 用户或旧提示词显式调用 release-ops-handoff
  not_when:
    - 新任务可以直接调用 release-handoff
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - canonical capability 需要输出发布交接
requires: []
related:
  - release-handoff
---

# Release Ops Handoff（单变更发版交接兼容入口）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager / DS**
- 触发时机：旧流程或旧提示词仍调用 `release-ops-handoff` 时
- 输出物：单变更发版交接卡
- 适用场景：单个功能、脚本、配置或跨项目小变更需要交给运维、运营、QA 或上线观察

---

## 兼容策略

本文件是兼容入口，不再维护独立正文模板。新任务必须路由到 canonical Skill：

```text
Skills/release-handoff.md
```

执行时：

1. 读取并遵守 `Skills/release-handoff.md`。
2. 使用 `mode=single`。
3. 基于 delivery evidence 输出 release owner、release registry root、release tag、范围、部署、验证、监控、回滚、运营使用和待确认项。
4. 若变更属于全量发版、多服务、SQL/脚本批次或需要统一 release 目录，升级为 `release-handoff(mode=train)`。

## 兜底输出

如果 canonical Skill 缺失，输出最小单变更发版交接卡：

```markdown
# 单变更发版交接卡

- 变更范围：
- Release Owner：
- Release Registry Root：
- Release Tag：
- Tag 目标 commit：
- SDD / TDD / PRD 落盘状态：
- 部署步骤：
- 验证证据：
- 运营 / QA 说明：
- 监控点：
- 回滚方案：
- 待确认项：
```

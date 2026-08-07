# 项目记忆

本目录保存经过证据和确认门禁的长期工程资产，不保存原始聊天、完整任务
记录、秘密、个人信息或临时运行状态。

## 文件职责

| 文件 | 内容 |
| --- | --- |
| `project-context.md` | 经验证的项目、领域和系统边界 |
| `decision-log.md` | 已确认决策、理由与替代关系 |
| `runbooks.md` | 已验证的重复操作 |
| `team-collaboration.md` | 非个人化、已确认的团队协作约定 |

个人协作画像和候选来源保存在 `.tic/local/`，必须 gitignored。

## 事实源边界

- 当前状态：以用户指定 ref 的代码、运行时和数据为准。
- 目标行为：以已确认 OpenSpec、PRD 和决策为准。
- 协作方式：以用户最新指令为准。
- 记忆冲突时先披露差异，不静默覆盖。

## 条目字段

```yaml
id: MEM-YYYYMMDD-NNN
scope: team | project
kind: project-fact | decision | anti-pattern | runbook
statement: ""
status: candidate | confirmed | deprecated | superseded
confidence: S1 | S2 | S3 | S4
evidence_refs: []
sensitivity: public | internal
confirmed_by: ""
valid_from: YYYY-MM-DD
review_after: YYYY-MM-DD
supersedes: []
```

使用 `collaboration-memory-maintainer` 提取、晋升、冲突处理、审计或废弃
条目。业务规则不能只在本目录转正，必须进入或引用 OpenSpec / PRD。

# 本地记忆候选队列

此文件可保存私人任务 ID 等本地来源线索，但不得保存原始聊天、秘密、PII
或生产业务明细。晋升到团队/项目资产时，必须换成团队可复核证据。

## 候选模板

```yaml
id: MEM-YYYYMMDD-NNN
scope: personal-local | team | project
kind: preference | project-fact | decision | anti-pattern | runbook
statement: ""
status: candidate
confidence: S1 | S2 | S3 | S4
evidence_refs: []
sensitivity: local-private
confirmed_by: ""
valid_from: YYYY-MM-DD
review_after: YYYY-MM-DD
supersedes: []
notes: ""
```

## Pending

## Promoted

晋升后只保留目标资产和条目 ID，不复制已提交内容。

## Discarded

只记录丢弃原因，不保留被过滤的敏感原文。

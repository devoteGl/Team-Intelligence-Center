---
schema: tic_capability.v1
id: candidate-rule-extractor
status: subflow
category: discovery
activation:
  when:
    - 用户明确要求从现有证据抽取候选业务规则
    - 已授权的调查发现隐含行为，需要单独记录候选
  not_when:
    - 没有可追溯证据
    - 用户要求直接修改正式规则或 PRD
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 规则 owner 需要候选清单进行确认
requires: []
related:
  - code-investigator
  - post-dev-prd-sync
---

# Candidate Rule Extractor（候选规则抽取能力）

## 技能用途

从已获准查看的代码、测试、Schema、配置或文档中提取可追溯候选。候选规则
不是正式规则；只有有权 owner 确认后才能进入正式事实源。

## 方法

1. 限定业务范围和证据来源，不默认全库扫描。
2. 抽取条件、行为、例外、状态变化和失败语义。
3. 合并重复证据；证据矛盾时保留冲突，不替用户决定。
4. 置信度使用 `direct | corroborated | inferred | unknown`，并解释判定依据。
5. 输出 0～N 条真实候选；没有发现时允许返回空列表。

```yaml
candidate_rules:
  - statement: ""
    conditions: []
    behavior: ""
    exceptions: []
    evidence: ["path:symbol-or-line"]
    confidence: direct | corroborated | inferred | unknown
    conflicts: []
    status: candidate
```

不得编造规则、遗漏来源、把推断写成确定事实，或自动写入 PRD、OpenSpec、
共享记忆等正式载体。

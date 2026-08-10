---
schema: tic_capability.v1
id: code-investigator
status: canonical
category: discovery
activation:
  when:
    - 用户要求解释、映射或追踪代码库中的现有行为
    - 关键实现事实未知，且会影响当前决策或修改
  not_when:
    - 当前任务已有足够上下文，可直接安全修改和验证
    - 仅因改动规模较大或出现 API、数据库、前端等关键词
side_effects: read-only
artifacts:
  default: none
  when_needed:
    - 异步消费者需要可引用的调查记录
requires: []
related:
  - candidate-rule-extractor
  - project-adapter-maintainer
---

# Code Investigator（代码调查能力）

## 技能用途

围绕一个真实问题查明现有代码事实、调用路径、业务约束和影响范围。它是按需
调查方法，不是每个开发任务的前置阶段。

## 激活边界

- 先写出本次要回答的问题；无法说明问题时，不启动全库调查。
- 从最小可信入口开始，例如符号、路由、命令、错误信息、测试或最近变更。
- 只有新证据指向更大范围时才扩展，不固定扫描前端、后端、数据库等视图。
- CodeGraph、LSP、`rg`、Git 历史和运行时日志都是可替换工具，不是硬依赖。

## 调查方法

1. 定义问题、已知事实、未知项和停止条件。
2. 找到入口与直接依赖，沿真实引用、调用或数据流追踪。
3. 用测试、配置、迁移、提交历史或运行结果交叉验证关键结论。
4. 标注行为来源、影响边界、反例和仍无法证明的部分。
5. 达到停止条件即返回，不为了“完整”继续扩张范围。

## 证据表达

默认直接在任务上下文中返回：

```yaml
question: ""
facts:
  - claim: ""
    evidence: ["path:line"]
uncertainties: []
affected_areas: []
```

- 事实与推断分开；行号易漂移时同时给出符号名或测试名。
- 候选业务规则必须带来源和置信度，不得自动升级为正式规则。
- 用户要求建议时，可以在事实之后给出独立的“建议”部分；不得把建议伪装成
  现有行为。
- 没有证据时明确说未知，不用固定报告模板填充空章节。

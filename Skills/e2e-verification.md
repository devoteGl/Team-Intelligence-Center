---
schema: tic_capability.v1
id: e2e-verification
status: canonical
category: verification
activation:
  when:
    - 局部检查无法证明重要用户旅程、跨层流程或高后果行为
  not_when:
    - 更低成本的测试已完整覆盖本次声明及受影响边界
    - 环境不可用且当前只需要诚实报告剩余风险
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 验收、审计或异步交接需要可复现证据
requires: []
related:
  - release-handoff
  - delivery-walkthrough
---

# E2E Verification（端到端验证能力）

## 技能用途

当组件测试、类型检查或局部运行不能证明关键旅程时，用尽量小的真实链路
验证声明。E2E 是证据强度选择，不是所有 UI 或跨层改动的固定关卡。

## 决策与准备

1. 写清要证明的旅程、关键断言、失败后果和局部检查留下的缺口。
2. 项目原生优先：读取项目 adapter 中的 runner、环境、认证、数据、清理和
   evidence root；不存在时选择最小可行适配器。
3. 使用隔离账号和可回收数据，不输出 secret、token、个人路径或生产数据。
4. 对 UI 声明验证真实界面与关键状态，而不只检查 DOM 或接口响应。

## 执行与判定

- 覆盖主路径以及与本次风险直接相关的失败/权限路径。
- 记录命令、环境、版本、数据前提、实际结果和可引用证据。
- 无论成功失败都执行清理；清理失败必须显式报告。
- 结果只取 `passed | failed | partial | blocked | waived`：
  - `partial`：部分旅程有证据，仍有未覆盖风险；
  - `blocked`：环境或权限阻止执行；
  - `waived`：有权决策者接受了明确的剩余风险。

```yaml
journey: ""
claim: ""
runner: ""
environment: ""
result: passed | failed | partial | blocked | waived
evidence: []
cleanup: passed | failed | not-applicable
remaining_risk: []
```

没有 fresh evidence 不得写 `passed`。截图、trace、视频和浏览器操作是证据或
适配器，不自动替代可重复断言。

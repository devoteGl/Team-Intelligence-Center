---
schema: tic_skill.v1
id: delivery-walkthrough
status: canonical
phase: closeout
role: PM / Tech Lead / QA / DS
risk_min: standard
inputs:
  - implementation_diff
  - verification_evidence
  - user_scope
outputs:
  - delivery_walkthrough
requires: []
delegates_to: []
---

# Delivery Walkthrough（交付走查技能）

## 技能用途

- 服务角色：**PM / Tech Lead / QA / DS**
- 触发时机：standard / critical 任务实现完成、用户要求“生成 walkthrough / 交付说明 / 走查文档”、需要异步 review 或验收交接时
- 输出物：面向 PM、Reviewer、QA、运营或使用方的交付 Walkthrough，可作为 `docs/walkthroughs/<change-id>.md` 或项目约定位置的交付 artifact
- 适用场景：功能实现说明、代码变更走查、UI/浏览器验证说明、架构改动说明、脚本交付使用说明、异步验收材料

> 本技能吸收 Agent Artifact / Walkthrough 的优点：任务完成后，用一份可审阅、可追溯、带证据的高层交付物说明“改了什么、怎么验证、怎么 review、还有什么风险”。

---

## 0. 核心原则

Walkthrough 是“完成态交付走查”，不是开工前计划，也不是发版 runbook。

必须做到：
- **先讲结果，再讲技术**：读者先知道本次交付解决了什么，再进入文件、流程和证据。
- **证据优先**：重要结论必须能追溯到需求、diff、测试、构建、截图、录屏、接口契约、日志或人工确认。
- **面向异步 review**：即使用户没有全程盯着 Agent 执行，也能通过 Walkthrough 快速恢复上下文。
- **区分事实和待确认**：未验证、未部署、未人工确认的内容必须写明，不得伪造成已完成。
- **可审阅、可复现、可验收**：必须告诉读者从哪里看代码、怎么跑验证、哪些路径最值得 review。

绝对禁止：
- 把 Walkthrough 写成流水账或工具调用记录。
- 只列文件，不解释用户可感知变化和验证结果。
- 隐藏未执行的验证、已知风险、环境依赖或回滚复杂度。
- 用推测替代证据，尤其是支付、权限、数据、生产配置和第三方回调相关结论。

---

## 1. 与其他技能的边界

| 目标 | 使用技能 |
| --- | --- |
| 开工前拆任务、排依赖 | `task-decomposer` |
| 实现前形成详细技术执行计划 | OpenSpec tasks / Superpowers planning / 项目计划机制 |
| 完成后让人快速理解和验收本次交付 | `delivery-walkthrough` |
| 发版、部署、运营使用、回滚和上线观察 | `release-handoff(mode=single)` |
| 多服务、多项目、SQL/脚本总控发版 | `release-handoff(mode=train)` |
| 开发后同步 PRD、候选规则和待确认项 | `post-dev-prd-sync` |
| 版本历史归档 | `changelog-writer` |

推荐链路：

```text
任务 / OpenSpec / SDD
  -> 实现与验证
  -> delivery-walkthrough
  -> release-handoff（需要上线交接时）
  -> post-dev-prd-sync / changelog-writer（需要文档沉淀时）
```

---

## 2. 必须收集的证据

能找到多少用多少；找不到的写入“证据缺口”。

| 证据类型 | 优先来源 | 用途 |
| --- | --- | --- |
| 需求与范围 | 用户消息、issue、PRD、OpenSpec、SDD、任务清单 | 说明为什么做、做到哪里 |
| 实现事实 | `git diff`、改动文件、commit、架构图、接口契约 | 说明实际改了什么 |
| 验证结果 | 测试、构建、lint、联调、脚本 dry-run、日志 | 证明交付可用 |
| UI / 浏览器证据 | Playwright、浏览器截图、录屏、Computer Use、Chrome | 证明界面和流程可见可操作 |
| 运行与部署线索 | README、env、配置、runbook、systemd、CI | 说明怎么运行、怎么部署 |
| 风险与缺口 | 未测项、环境限制、已知缺陷、回滚难点 | 让 reviewer 能做风险判断 |

---

## 3. 输出位置

优先遵守项目 `AGENTS.md`、`ai-harness/project-adapter.md`、OpenSpec change 或用户指定位置。Walkthrough 的归属应与本次 SDD / PRD / Release Handoff 的主归属一致；多项目任务只设一个主 Walkthrough，其他项目作为引用或子项。

未声明时建议：
- 单变更 Walkthrough：`docs/walkthroughs/<change-id>.md`
- 发版批次内 Walkthrough：`<release-registry-root>/<version>/walkthrough.md`
- 脚本 / 工具使用 Walkthrough：放在该工具目录或 `docs/operations/`
- UI 证据资产：`docs/walkthroughs/assets/<change-id>/`

如果只是当前对话的最终说明，允许不落文件；但 standard / critical、跨端、UI 或运维交接场景建议生成 Markdown 文件。

---

## 4. 工作流程

1. 判定 Walkthrough 读者：PM、代码 reviewer、QA、运维、运营、终端使用方或混合读者。
2. 明确本次交付范围：已完成、未完成、不包含什么。
3. 汇总业务可感知变化：用户、运营或系统行为发生了什么变化。
4. 汇总技术实现：按模块、层级或数据流组织，不按命令时间线组织。
5. 列出变更文件和影响面：说明新增、修改、删除、配置、数据、权限、第三方依赖。
6. 整理验证证据：自动化、手动、UI/浏览器、未执行验证分别列清。
7. 给出 review 指引：建议从哪些文件、路径、接口、状态流转或风险点开始看。
8. 标注剩余风险和待确认项：区分阻塞、重要、可后续。
9. 如需上线交接，明确指向 `release-handoff(mode=single|train)` 或补充发版入口。

---

## 5. 输出模板

```markdown
# <变更名称> - Delivery Walkthrough

## 1. 交付摘要
- **一句话结论**：<本次交付让谁能做什么 / 解决了什么问题>
- **当前状态**：Ready for Review / Ready for QA / Ready for Release / Needs Confirmation
- **关联来源**：<issue / PRD / OpenSpec / SDD / 用户请求 / 分支 / commit>
- **适用读者**：<PM / Reviewer / QA / 运维 / 运营 / 使用方>

## 2. 本次完成了什么
| 项 | 说明 | 证据 |
| --- | --- | --- |
| <能力 / 行为> | <变化说明> | <文件 / 测试 / 截图 / 日志> |

## 3. 用户可见变化 / 使用路径
1. <入口或触发方式>
2. <关键流程>
3. <完成后的结果>

> 如果是纯后端、脚本或基础设施任务，改写为“调用方式 / 执行路径 / 运维使用方式”。

## 4. 技术实现走查
### 架构 / 数据流
<文字说明或 Mermaid 图。只在能帮助理解时使用图。>

### 关键设计决策
| 决策 | 原因 | 取舍 |
| --- | --- | --- |
|  |  |  |

## 5. 变更文件与影响面
| 文件 / 模块 | 类型 | 影响 |
| --- | --- | --- |
|  | 新增 / 修改 / 删除 / 配置 |  |

## 6. 验证证据
### 已执行
| 验证项 | 命令 / 方法 | 结果 | 证据 |
| --- | --- | --- | --- |
|  |  | 通过 / 失败 / 不适用 |  |

### UI / 浏览器证据
| 证据 | 路径 / 链接 | 说明 |
| --- | --- | --- |
| 截图 / 录屏 / 手动验收 |  |  |

### 未执行
| 验证项 | 原因 | 剩余风险 | 建议补救 |
| --- | --- | --- | --- |
|  |  |  |  |

## 7. Review 指引
- 建议优先 review：<文件、函数、接口、状态流转>
- 重点确认：<权限、数据、边界、异常、性能、兼容性>
- 可以跳过：<纯生成、样式微调、无行为变化文件>

## 8. 风险与待确认
| 级别 | 内容 | 处理建议 |
| --- | --- | --- |
| 阻塞 / 重要 / 后续 |  |  |

## 9. 后续动作
- <QA 验收 / 发版交接 / PRD 同步 / Changelog / 运营培训 / 监控观察>
```

---

## 6. 写作规则

- 标题使用具体变更名，不使用“本次修改总结”这类空泛标题。
- 摘要不超过 5 行；细节放到后续章节。
- 代码文件用相对路径或项目可点击路径；跨仓库时标注仓库名。
- 截图、录屏、日志、测试输出只引用关键证据，不粘贴长篇原文。
- 验证结果必须写清命令 / 方法和结果；未执行的验证必须单独列出。
- 若验证输出经过 rtk 等工具压缩，必须标注过滤方式；关键结论仍以原生命令 exit code、stderr 和完整日志或 raw 输出为准。
- UI 任务优先附截图或录屏；无法获取时写明原因和替代验证。
- 复杂架构用 Mermaid 图辅助，但图只表达关键链路，不追求覆盖所有实现细节。
- 面向运营或非研发读者时，把“如何使用”和“异常时怎么办”提前。
- 面向 reviewer 时，把“变更文件与影响面”和“Review 指引”提前。

---

## 7. 质量自检清单

输出前检查：

- [ ] 读者能在 1 分钟内知道本次交付解决了什么。
- [ ] 每个关键结论都有证据或明确标注待确认。
- [ ] 文件清单说明了影响，而不是只堆路径。
- [ ] 验证包含已执行和未执行两类。
- [ ] UI / 浏览器任务附了截图、录屏或说明了无法附证据的原因。
- [ ] Review 指引指出了最值得看的代码和风险点。
- [ ] 没有把发版步骤、PRD 正式规则或 Changelog 混进 Walkthrough 主体；需要时只做跳转或后续动作。

---

## 8. 最终报告要求

执行本技能后，最终报告必须包含：
- Walkthrough 是否已生成文件，以及文件路径。
- 使用了哪些证据来源。
- 哪些验证已经完成，哪些仍未覆盖。
- 后续是否还需要 `release-handoff`、`post-dev-prd-sync` 或 `changelog-writer`。

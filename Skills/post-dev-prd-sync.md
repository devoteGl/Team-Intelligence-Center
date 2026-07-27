---
schema: tic_skill.v1
id: post-dev-prd-sync
status: canonical
phase: closeout
role: DS / PM
risk_min: standard
inputs:
  - delivery_evidence
  - behavior_changes
  - candidate_rules
outputs:
  - prd_update_draft
  - pending_confirmations
requires: []
delegates_to: []
---

# Post Dev PRD Sync（开发后 PRD 同步技能）

## 技能用途
- 服务角色：**DS (Doc Specialist) / PM**
- 触发时机：standard / critical 任务开发完成、验收通过、发版前整理、用户要求“补 PRD / 归档 / 同步文档”时
- 输出物：PRD 更新草稿、证据清单、待确认事项、可选 Changelog 输入
- 适用场景：用户可见行为、UI/交互、API 契约、数据模型、状态流转、业务规则或运营流程发生变化后的文档同步

> 本技能不替代 `ai-prd-generator.rules.md` 和 `ai-prd-editor.rules.md`。
> 它是开发完成后的编排层：用证据生成 PRD 更新草稿，再由人工确认后转正。

---

## 0. 核心原则

开发后补 PRD 不能变成“事后编故事”。AI 只能基于证据整理草稿，不能把推断自动写成正式业务事实。

必须遵守：
- 证据优先：每条重要结论都要能追溯到 OpenSpec、SDD、git diff、测试、UI 验证、接口契约或用户确认。
- 可信度标注：沿用 `ai-prd-editor.rules.md` 的 S1-S4 体系。
- 草稿优先：未人工确认前，输出为 PRD 更新草稿或候选规则，不直接转正进 `main-prd.md`。
- 归属优先：PRD、SDD 和 TDD 证据落盘到拥有该产品行为的项目/子项目/父工作区，不按当前 shell 目录随意落盘。
- 小改轻量：纯重构、格式化、注释、内部实现优化且无行为变化时，不强制生成 PRD 草稿。

---

## 1. 自动触发条件

standard / critical 任务完成后，AI 应自动判断是否需要执行本技能。

需要执行：
- 用户可见行为变化。
- UI、页面布局、交互状态、表单流程或可视化回归变化。
- API 契约、字段、错误码、权限、枚举或状态流转变化。
- 数据模型、数据库约束、迁移脚本或初始化数据变化。
- 业务规则、运营流程、发版流程或验收标准变化。
- 用户明确说“补 PRD”“更新文档”“归档本次需求”“发版前整理”。

不需要执行：
- 纯格式化、lint、注释调整。
- 测试补充但不改变产品行为。
- 内部重构且无外部行为、接口、数据或流程变化。
- 只读咨询、代码解释和 micro 级非行为改动。

---

## 2. 证据收集

执行前先收集以下证据，能找到多少用多少；找不到的必须写入缺口。

| 证据类型 | 优先来源 | 用途 |
| --- | --- | --- |
| 需求与规格 | OpenSpec change、SDD、tasks、issue、用户消息 | 确认目标范围和验收标准 |
| 代码事实 | `git diff`、commit、改动文件、CodeGraph 影响面 | 确认实际实现了什么 |
| 验证证据 | 测试、构建、lint、接口联调、UI 截图、Playwright / Computer Use 记录 | 确认交付是否可用 |
| 契约资料 | API 契约、字段说明、数据库迁移、配置说明 | 确认跨端和数据影响 |
| 既有文档 | `docs/PRD/`、`PRD/main-prd.md`、`openspec/specs/`、`ai-harness/memory/` | 判断需要新增、更新还是候选化 |

---

## 3. 归属与落盘

优先遵守项目 `AGENTS.md`、`ai-harness/project-adapter.md` 或 PRD 元信息中的约定。

必须先确认：

- `artifact_owner_type`：`workspace` / `project` / `subproject` / `external`。
- `artifact_owner_id`：稳定项目标识或工作区标识。
- `sdd_root`：SDD / OpenSpec change 的落盘根。
- `tdd_evidence_root`：测试、构建、联调、UI 验证等证据索引的落盘根。
- `prd_root`：正式 PRD 或长期产品文档根。
- `prd_draft_root`：PRD 更新草稿根。
- 多项目变更的主归属和引用关系；无法确认时写“待确认”，不得把草稿分散写到多个项目并各自声称为正式事实。

未声明时建议：
- SDD / OpenSpec：已有 `openspec/` 时使用 `openspec/changes/<change-id>/`；否则使用 `docs/sdd/<change-id>.md`
- TDD 证据索引：`docs/test-evidence/<change-id>/README.md`，具体测试代码仍放在项目测试目录
- PRD 草稿：`docs/PRD/drafts/<change-id>-prd-update.md`
- 候选规则：`docs/PRD/pending-candidates.yaml` 或项目已有候选规则位置
- Changelog 输入：交给 `Skills/changelog-writer.md`，不要在 PRD 草稿里写流水账
- 稳定规格：人工确认后再同步到 `openspec/specs/` 或 `PRD/main-prd.md`

---

## 4. PRD 更新草稿模板

```markdown
# <需求 / 变更名称> PRD 更新草稿

## 0. 元信息
- **状态**：Draft / Needs Confirmation / Ready for Review
- **关联变更**：<OpenSpec change / issue / branch / commit>
- **归属**：<artifact_owner_type / artifact_owner_id>
- **落盘位置**：<prd_draft_root / sdd_root / tdd_evidence_root>
- **生成日期**：YYYY-MM-DD
- **证据范围**：<diff、测试、截图、契约、用户确认>

## 1. 本次变更摘要
- <一句话说明本次交付改变了什么>

## 2. 已确认行为（S1 / S2）
| 编号 | 行为 / 规则 | 证据来源 | 可信度 |
| --- | --- | --- | --- |
| R-XXX |  |  | S1 / S2 |

## 3. 用户流程 / UI 变化
| 页面 / 流程 | 变化说明 | 验证证据 |
| --- | --- | --- |

## 4. API / 数据 / 状态影响
| 对象 | 变化 | 证据来源 | 是否需同步契约 |
| --- | --- | --- | --- |

## 5. 验收标准与验证结果
| AC | 验收条件 | 验证方式 | 结果 |
| --- | --- | --- | --- |

## 5.1 SDD / TDD 落盘状态
| 类型 | 路径 / 链接 | 状态 | 说明 |
| --- | --- | --- | --- |
| SDD / OpenSpec |  | 已落盘 / 待补 / 不适用 |  |
| TDD / 验证证据 |  | 已落盘 / 待补 / 不适用 |  |
| PRD 草稿 / 正式稿 |  | 已落盘 / 待确认 / 不适用 |  |

## 6. 候选规则与待确认项
| 编号 | 内容 | 原因 | 可信度 | 建议处理 |
| --- | --- | --- | --- | --- |

## 7. 不纳入本次 PRD 的内容
- <明确不做、纯技术实现、无行为变化内容>
```

---

## 5. 转正规则

AI 可以自动生成草稿，但不能自动完成转正。

转正前必须满足：
- S3 / S4 内容已由人工确认或保留为待确认项。
- 与既有 `main-prd.md`、OpenSpec specs 或 API 契约不存在未处理冲突。
- PRD 更新草稿通过 `Skills/prd-review-checklist.md` 的关键检查。
- 若涉及版本归档，已交给 `Skills/changelog-writer.md` 生成或更新双层 Changelog。

转正后需要记录：
- 转正时间。
- 人工确认人或确认来源。
- 关联 commit / change / release。
- 被替换或废弃的旧规则。

---

## 6. 最终报告要求

执行本技能后，最终报告必须包含：
- 生成或更新了哪些 PRD / Changelog / 候选规则文件。
- 使用了哪些证据来源。
- 哪些内容是已确认事实，哪些仍需人工确认。
- 未能自动验证或未能同步的剩余风险。

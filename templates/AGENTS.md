# Team-Intelligence-Center 轻量规则

本项目使用 Team-Intelligence-Center 作为轻量 AI 协作规则层。

规则来源：`{{TIC_RULES_DIR}}`
规则版本：`{{TIC_VERSION}}`

## 工作原则

- 简单任务保持简单。咨询、只读查询、代码解释、微小非行为改动，不走完整 PRD/SDD/Plan 流程。
- standard / critical 任务执行 SDD + TDD。先明确行为规格，再基于验收标准编写或更新测试，最后实现。
- 项目已有 `openspec/`，或任务涉及跨模块、API、数据模型、长期产品行为时，优先用 OpenSpec 承载规格；没有 OpenSpec 时，把 SDD 放到 `docs/sdd/` 或项目约定位置。
- 按风险升级，而不是按关键词升级。支付、认证、数据迁移、生产配置、安全、删除、跨模块契约需要更严格处理。
- 改代码前先读本项目上下文，优先复用现有模式、命令、测试和文档。
- 完成前必须验证。最终说明要写清楚跑了哪些命令、哪些通过、哪些未测、还有什么风险。
- 不编造业务事实。反推到的行为要标注可信度，候选规则确认前不得写成正式需求。
- 不覆盖人的工作。保留项目已有规则和用户未提交改动。

## 任务分级

| 档位 | 适用场景 | 处理要求 |
| --- | --- | --- |
| consulting | 解释、对比、只读 review、流程讨论 | 直接回答并给证据，不改文件。 |
| micro | 文案、注释、文档、微小非行为改动 | 做窄改动，跑最小有意义验证。 |
| standard | 新功能、行为变化、API/UI 契约、跨模块改动 | 写或更新 SDD，从验收标准推导 TDD 测试，实现后验证。 |
| critical | 支付、认证、安全、生产配置、破坏性迁移、数据丢失风险 | 需要明确人工确认、SDD + TDD 证据、回滚思路、更强验证和清晰发版说明。 |

## SDD + TDD 原则

- SDD 定义目标行为、范围、不做什么、验收标准和边界场景。
- TDD 把 SDD 的验收标准转成失败测试或明确验证项，再进入实现。
- 实现必须能追溯到 SDD 和测试。
- OpenSpec 可以作为 SDD 的存储和生命周期承载方式，但 consulting 和 micro 任务不强制使用 OpenSpec。
- 不把未确认的代码反推当成既定业务事实；老项目反推规则要使用可信度标签和候选规则机制。

## UI 验证规则

涉及 UI、页面布局、交互状态、样式、响应式、表单流程或可视化回归的变更时，AI 应优先核对真实界面。

- 本地应用可运行时，优先使用 Playwright、浏览器截图、Computer Use 或 Chrome 打开页面并核对。
- 需要登录、桌面 App、用户本机状态、真实浏览器插件或账号态时，可以使用 Computer Use / Chrome 辅助验证。
- 核对重点：页面是否可打开、核心流程是否可操作、样式是否错位、桌面/移动端是否异常、控制台是否有关键错误。
- micro 级纯文案或无行为样式微调，可只做最小截图、局部检查或说明级验证。
- 无法运行或自动核对界面时，最终报告必须说明原因、替代验证内容和剩余 UI 风险。

## 推荐使用的 TIC 资产

- 全局行为规则：`Global-Rules/coding-rules.md`
- 新需求生成：`Prompts/ai-prd-generator.rules.md`
- 老项目补文档：`Prompts/ai-prd-editor.rules.md`
- OpenSpec / Superpowers 接合：`Design/development-paradigm-openspec-guide.md`
- 代码调研：`Skills/code-investigator.md`
- 任务拆解：`Skills/task-decomposer.md`
- API 契约冻结：`Skills/api-contract-freezer.md`
- 候选规则抽取：`Skills/candidate-rule-extractor.md`
- 发版交接：`Skills/release-ops-handoff.md` 和 `Skills/release-train-handoff.md`

## 完成报告

涉及代码或文档改动时，最终报告应包含：

- 修改了哪些文件。
- 做了哪些简化或关键决策。
- 执行了哪些验证命令和结果。
- 未覆盖的验证和剩余风险。

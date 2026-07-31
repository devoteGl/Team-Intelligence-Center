# TIC 0.3.0 E2E 验证标准化 - Delivery Walkthrough

## 1. 交付摘要

- **一句话结论**：TIC 现在能按验收标准和风险决定是否进入 E2E gate，并用统一契约管理 runner、环境、认证、数据、证据、清理和 verdict。
- **当前状态**：Ready for Release；本地验证与逻辑 review 通过，PowerShell
  运行时 fixture 作为长期验证项，不阻塞本次发布。
- **关联来源**：用户讨论、`docs/sdd/tic-0.3.0-e2e-verification-standardization.md`、`feature/e2e-verification-standardization`。
- **适用读者**：规则维护者、Reviewer、QA、Tech Lead、使用 TIC 的项目 owner。

## 2. 本次完成了什么

| 项 | 说明 | 证据 |
| --- | --- | --- |
| canonical E2E Skill | 统一触发判断、工具职责、生命周期、安全边界和 verdict | `Skills/e2e-verification.md` |
| 总控条件路由 | Verification phase 按风险调用 E2E，不强制所有 micro | `Skills/tic-workflow-orchestrator.md` |
| adapter schema | 记录 policy、runner、命令、认证、数据、清理、journey 和证据根 | adapter 模板与 bootstrap |
| Codex wrapper | 全局只安装轻量入口，运行时读取项目 canonical Skill | `templates/codex-global/skills/tic-e2e-verification/` |
| Closeout / Release 接合 | Walkthrough 与 Release Handoff 接收 E2E verdict 和证据 | 两个 canonical Skill |
| 回归门禁 | 验证路由、schema、保留语义、wrapper 和安全边界 | `tools/validate-pack.sh` |
| marker 幂等修复 | refresh 不再在 `AGENTS.md` 文件末尾累积空白行 | Shell / PowerShell bootstrap 与幂等 fixture |

## 3. 项目使用路径

1. `tic-workflow-orchestrator` 从验收标准和风险判断 E2E 为 `not-required`、`targeted`、`required` 或 `required-gate`。
2. 触发时读取项目 `ai-harness/project-adapter.md` 的 `verification.e2e`。
3. 优先运行项目已有的 E2E、API、集成或系统测试。
4. Web 项目需要新增可重复套件且未声明 runner 时，可选择 Playwright Test。
5. MCP、Browser、Chrome、Computer Use、截图和 trace 用于探索、调试或可观察证据。
6. 结果写入 `passed`、`failed`、`partial`、`blocked` 或 `waived`，并记录未测项和风险。

老项目普通更新不会自动改 adapter。需要新增 schema 时，显式调用 `project-adapter-maintainer(mode=migrate)`，只补缺失字段并保留现有非占位内容、自定义章节和本地决策。

## 4. 技术实现走查

```text
Acceptance criteria
  -> Orchestrator decides E2E requirement
  -> e2e-verification reads project adapter
  -> project-native runner first
  -> prepare isolated environment / auth / data
  -> execute affected journeys
  -> collect redacted evidence
  -> cleanup owned data
  -> honest verdict
  -> Walkthrough / Release Handoff
```

关键设计决策：

| 决策 | 原因 | 取舍 |
| --- | --- | --- |
| 条件 gate 而非全量强制 | 保持 adaptive workflow，避免 micro 成本失控 | 每次 standard / critical 需显式判断 |
| 项目原生 runner 优先 | 尊重既有测试体系和 CI 事实源 | TIC 不提供统一 runner 脚手架 |
| Playwright Test 只做默认候选 | 市场成熟且适合可重复 Web E2E | 不形成强制依赖 |
| MCP / Browser / Computer Use 是适配层 | 适合探索、真实账号态和调试 | 默认不能单独证明完整 CI 通过 |
| adapter 保护性迁移 | E2E 配置属于项目事实 | 老项目需要显式 migrate |
| `disabled` 不等于 passed | 避免项目策略掩盖 critical 风险 | critical 需阻塞或责任人豁免 |
| 认证方式与状态策略分离 | 未知项目不能把 `local-only` 伪装成认证方式 | `auth_mode` 待确认，`auth_state_policy` 固定安全边界 |

## 5. 变更文件与影响面

| 文件 / 模块 | 类型 | 影响 |
| --- | --- | --- |
| `Skills/e2e-verification.md` | 新增 | E2E canonical contract |
| `Skills/tic-workflow-orchestrator.md` | 修改 | Verification 条件路由 |
| `Skills/project-adapter-maintainer.md` | 修改 | 保护性迁移 E2E schema |
| `Skills/project-governance-bootstrap.md` | 修改 | 新项目治理模板 |
| `Skills/delivery-walkthrough.md`、`Skills/release-handoff.md` | 修改 | E2E 证据进入收尾与发版 |
| `templates/ai-harness/project-adapter.md` | 修改 | 新 schema |
| `tools/bootstrap-project.sh/.ps1` | 修改 | 首次生成 schema 对齐 |
| `templates/codex-global/skills/tic-e2e-verification/` | 新增 | Codex 全局 wrapper |
| `tools/validate-pack.sh` | 修改 | 规则和安装回归 |
| README、USAGE、Global-Rules、templates、docs、manifest、VERSION | 修改 / 新增 | 0.3.0 规则、说明和归档 |

## 6. 验证证据

### 已执行

| 验证项 | 命令 / 方法 | 结果 |
| --- | --- | --- |
| 规则包 | `bash tools/validate-pack.sh` | `Validation passed.` |
| Shell 语法 | `bash -n tools/*.sh` | 通过 |
| manifest | `jq empty manifest.json` | 通过 |
| diff 格式 | `git diff --check` | 通过 |
| Skill wrapper | `quick_validate.py` | 通过 |
| 临时 Codex 安装 | 隔离 `--codex-home` 安装并断言 wrapper | 通过 |
| adapter 保留 / 重生成 | `validate-pack.sh` 临时 fixture | 通过 |
| marker 幂等 / 自愈 | 连续 refresh，并注入旧版尾部空行后复测 | 通过 |
| 业务工作区接入 | 父工作区 + 7 个已接入子项目本地 refresh | 8/8 通过 |

E2E 结果索引见 `docs/test-evidence/tic-0.3.0/README.md`。规则包变更的
requirement 为 `targeted`，verdict 为 `passed`；业务工作区没有产品行为变化，
因此产品级 E2E 为 `not-required`，接入链路 targeted smoke 已通过。

### 未执行

| 验证项 | 原因 | 剩余风险 | 建议补救 |
| --- | --- | --- | --- |
| PowerShell 运行时 fixture | 当前环境无 `pwsh` | Windows 运行时差异 | 已接受为长期验证项，在 Windows / pwsh CI 补跑 |
| 业务浏览器 E2E | 本仓库无业务应用 | 不覆盖具体业务旅程 | 由接入项目执行 |
| release / tag / stable 更新 | 未获发版 Git 授权 | 尚未进入稳定通道 | 用户确认后执行 |

## 7. Review 指引

- 优先看 `Skills/e2e-verification.md` 的 gate、provider 边界、认证和清理规则。
- 对照三处 adapter schema：模板、Shell、PowerShell 必须一致。
- 核对 `tic-workflow-orchestrator` 是否仍只做路由且少于 280 行。
- 核对 `project-adapter-maintainer` 是否继续保留非占位事实和未知字段。
- 核对 `validate-pack.sh` 是否同时证明普通刷新保留旧 adapter、显式重生成包含新 schema。
- 核对 docs 没有把 Playwright、MCP、Browser、Chrome 或 Computer Use 写成强制依赖。

## 8. 风险与待确认

| 级别 | 内容 | 处理建议 |
| --- | --- | --- |
| 后续 | PowerShell 未做运行时测试 | 已明确接受为长期验证项，在 Windows / pwsh 环境持续补证据 |
| 后续 | 业务项目已有 adapter 不会自动补字段 | 升级后按需调用 `project-adapter-maintainer(mode=migrate)` |
| 待确认 | 0.3.0 Git 提交、release 分支、tag、push 与回灌 | 按 `git-flow-operator` 单独确认 |

## 9. 后续动作

- 用户审阅本次逻辑和文件差异。
- 确认后提交功能分支；再按 Git Flow 创建 `release/0.3.0`。
- PowerShell 证据在后续 Windows / pwsh 环境持续补齐。
- tag / push 后回填远端 tag、stable 更新和项目升级证据。

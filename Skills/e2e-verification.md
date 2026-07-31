---
schema: tic_skill.v1
id: e2e-verification
status: canonical
phase: verification
role: QA / Test Engineer / Tech Lead
risk_min: standard
inputs:
  - acceptance_criteria
  - effective_risk_tier
  - project_adapter
  - changed_surfaces
outputs:
  - e2e_requirement_decision
  - e2e_verification_plan
  - e2e_verdict
  - verification_evidence_index
requires: []
delegates_to: []
---

# E2E Verification（端到端验证技能）

## 技能用途

- 服务角色：**QA / Test Engineer / Tech Lead**
- 触发时机：standard / critical 任务改变用户旅程、跨层交互、关键 API 流程、认证、权限、资金或跨服务链路，或者用户明确要求端到端验证
- 输出物：E2E 必要性判断、受影响旅程、执行计划、证据索引、verdict、未测项与剩余风险
- 适用场景：Web、API、桌面 App、浏览器插件、移动端或多服务系统的验收驱动验证

本技能定义验证契约和证据门禁，不绑定某个测试框架，也不替业务项目安装测试工具。

---

## 0. 核心原则

- **验收标准驱动**：先把验收标准映射为用户或系统可观察旅程，再选择 runner 和工具。
- **项目原生优先**：项目已有 E2E、API、集成或系统测试命令时，以它们作为主要事实源。
- **风险决定深度**：验证受影响的核心旅程，不把“全量浏览器回归”机械应用到所有任务。
- **可重复证据优先**：自动化套件的命令、exit code、断言和报告优先于一次性探索操作。
- **工具是适配层**：Playwright Test、Playwright MCP、Browser、Chrome、Computer Use 或其他能力可替换；TIC 只约束输入、生命周期、证据和结论。
- **安全数据闭环**：认证状态本地保存且 gitignored；只清理本次验证拥有的数据，不执行范围不明的删除。
- **诚实 verdict**：`partial`、`blocked` 或 `waived` 不得写成 `passed`。

禁止：

- 仅凭页面能打开、一次点击成功或 Agent 主观判断宣布完整 E2E 通过。
- 将 Token、密码、cookie、storage state、验证码、个人绝对路径或生产数据写入可提交证据。
- 未经确认使用生产账号、真实资金、真实通知、生产写入或不可逆清理。
- 在项目已有 runner 时，为了统一工具名称无理由重建一套测试体系。

---

## 1. 判断是否进入 E2E Gate

| 档位与影响 | 默认结论 |
| --- | --- |
| consulting | `not-required` |
| micro 且无行为变化 | `not-required`，执行最小验证 |
| micro 且有局部交互 | 对受影响路径做窄范围真实界面验证 |
| standard 且改变用户旅程、跨层交互或关键 API 流程 | `required`，验证受影响核心旅程 |
| critical，或涉及认证、权限、资金、隐私、迁移、跨服务关键链路 | `required-gate`；缺失时不得静默完成 |

以下情况通常需要升级验证深度：

- 一个验收标准跨越 UI、API、状态存储、消息、第三方回调或多个服务。
- 单元测试无法证明用户最终可观察结果。
- 回归只能通过真实导航、输入、权限态、账号态或多步骤状态转换发现。
- 失败会影响资金、访问控制、隐私、关键运营流程或发布门禁。

仅出现“UI”“API”“登录”等关键词不自动要求全量 E2E；应结合破坏性、影响面、可恢复性、外部副作用和验证成本判断。

输出：

```yaml
e2e_requirement:
  decision: not-required | targeted | required | required-gate
  reason: ""
  affected_journeys: []
  acceptance_criteria: []
```

---

## 2. 解析项目配置与工具

优先读取：

1. 项目 `AGENTS.md`、`.tic-rules.lock` 和 `ai-harness/project-adapter.md`。
2. CI、README、package scripts、Makefile、测试配置和已有 E2E 目录。
3. 本次 SDD / OpenSpec 的验收标准及变更范围。
4. 当前环境实际可用的测试、浏览器和 Computer Use 能力。

项目 adapter 可声明：

```yaml
verification:
  e2e:
    policy: risk-based # disabled | risk-based | required
    runner: project-native # project-native | playwright-test | api-suite | manual-assisted | 待确认
    start_command: ""
    test_command: ""
    base_url: ""
    test_root: ""
    evidence_root: "docs/test-evidence"
    auth_mode: "待确认" # none | fixture | storage-state | interactive | external | 待确认
    auth_state_path: ""
    auth_state_policy: local-only
    data_strategy: "待确认" # isolated | seeded | disposable | external | 待确认
    setup_command: ""
    cleanup_command: ""
    core_journeys: []
```

字段为空时不得伪造命令或账号。项目未声明时，从已存在的配置中提出候选值；需要写回 adapter 时使用 `project-adapter-maintainer` 做保护性 `enrich` 或 `migrate`。

`policy` 的处理：

- `risk-based`：按第 1 节判断。
- `required`：所有有行为变化的 standard / critical 任务至少执行受影响旅程；无行为变化仍可记录 `not-required`。
- `disabled`：表示项目明确不运行 E2E，不等于验证通过。若本次判断为 `required-gate`，必须输出 `blocked`，或者由有权责任人确认 `waived` 并记录替代证据和风险。

`evidence_root` 为空时跟随 `artifact_roots.tdd_evidence_root`；两者都存在但不一致时，以显式 E2E 配置为本次证据根，并在结果中记录差异，避免静默分散证据。

### 工具选择

| 场景 | 主要事实源 | 辅助能力 |
| --- | --- | --- |
| 项目已有可重复 E2E 套件 | 项目原生 test command 与报告 | 浏览器、trace、截图用于调试 |
| Web 项目需新增可重复套件，且未指定 runner | Playwright Test 是默认候选 | Playwright MCP / Browser / Chrome |
| 真实账号态、本机浏览器状态、插件或桌面 App | 项目自动测试 + 可观察证据 | Computer Use / Chrome / Browser |
| 无 UI 的服务链路 | API、契约、集成或系统测试 | 日志、trace、测试数据核对 |
| 探索未知流程或定位失败 | 现有测试结果 | MCP / 浏览器 / Computer Use 探索 |

探索性工具默认不是 CI 通过的替代品。只有验收标准明确接受可观察验证，且证据能复核时，才可作为主要证据，并必须说明不可重复部分。

---

## 3. 验证生命周期

### Step 1：建立验收映射

为每条验收标准记录：

- 起始状态和角色。
- 操作步骤或系统事件。
- 最终可观察结果。
- 关键断言。
- 需要的环境、账号、fixture 和清理范围。
- 失败时应保留的日志、截图、trace 或响应。

只选择本次变更影响的核心旅程；critical 可增加相邻高风险回归路径。

### Step 2：Preflight

在启动或写入前检查：

- runner、命令、base URL 和测试目录是否来自项目证据。
- 目标是否为本地、隔离测试或明确授权的环境。
- 认证方式是否可用，认证状态路径是否为项目相对路径且已 gitignored。
- 测试数据是否隔离，清理命令是否只作用于本次拥有的数据。
- 依赖服务、端口、浏览器和外部 sandbox 是否可用。
- `evidence_root` 与 artifact owner 是否一致。

不满足安全边界时停止并输出 `blocked`；不得通过使用生产数据或扩大权限绕过。

### Step 3：准备环境、认证与数据

- 优先使用项目声明的 `start_command`、`setup_command` 和 fixture。
- 可逆本地启动、隔离数据准备和非破坏性验证可连续执行，不因阶段切换机械暂停。
- 认证状态只保存在本机，并在证据中记录“使用何种方式”，不记录秘密值。
- 为本次创建的数据加可识别前缀、run id 或 fixture 标识，便于精确清理。

### Step 4：执行旅程

- 先运行最小、最相关的 journey；需要时再扩展相邻回归。
- 保存原生命令、exit code、失败断言和关键 stderr。
- UI 旅程按验收需要核对导航、输入、状态、响应式、控制台和关键网络请求。
- API / 服务旅程核对状态码、业务结果、持久化状态、事件或下游可观察结果。
- 出现失败先区分产品缺陷、测试缺陷、环境缺陷和数据缺陷，不把重试成功自动视为稳定通过。

### Step 5：收集证据

最小证据包括：

- change id、commit / 工作树基线、执行时间和目标环境类别。
- journey 与验收标准映射。
- runner、命令和 exit code。
- 通过、失败、跳过数量及关键断言。
- 适用时的报告、trace、截图、录屏、控制台或网络日志路径。
- 已做脱敏说明、未测项和剩余风险；URL 查询参数、header、cookie、Token、个人信息和业务敏感数据必须在可提交证据中脱敏。

二进制大文件按项目策略保存；证据索引只记录可复核路径，不内嵌秘密或大段原始数据。

### Step 6：清理

- 只运行项目已声明且范围清晰的 `cleanup_command`，或精确删除本次 run 创建的数据。
- 清理前无法证明所有权时不删除，输出待清理项和责任人。
- 不因测试失败而跳过必要的安全清理；清理失败单独记录。

### Step 7：形成 verdict

| Verdict | 含义 |
| --- | --- |
| `passed` | 所有必测旅程通过，证据与清理状态完整 |
| `failed` | 已执行但存在失败断言或阻断性错误 |
| `partial` | 仅部分必测旅程完成 |
| `blocked` | 环境、账号、依赖或安全边界导致无法执行 |
| `waived` | 明确责任人批准不执行，并记录原因、替代证据和风险 |

critical 的 `blocked`、`partial` 或 `waived` 必须进入完成报告和 Release Handoff（如触发），不得省略。

---

## 4. 输出格式

```markdown
## E2E Verification Result

- Change:
- Effective tier:
- Requirement: not-required / targeted / required / required-gate
- Runner:
- Environment: local / isolated-test / staging / other
- Verdict: passed / failed / partial / blocked / waived
- Evidence root:

### Journey coverage
| Journey | Acceptance criterion | Method | Result | Evidence |
| --- | --- | --- | --- | --- |

### Environment and data
- Start:
- Auth:
- Data setup:
- Cleanup:

### Gaps and risk
- Not tested:
- Remaining risk:
- Blocker or waiver owner:
- Follow-up:
```

`not-required` 仍应在 standard / critical 计划或完成报告中简要记录判断理由，避免把“未执行”误解为遗漏。

---

## 5. 必须暂停的边界

- 需要新凭据、验证码、人工登录或未授权账号。
- 目标是生产环境、真实资金、真实通知或外部不可逆写入。
- 清理范围不明确，可能删除非本次创建的数据。
- 多个环境或 runner 选择会实质改变成本、风险或验证结论。
- critical gate 需要豁免、降级或缩小必测范围。

除上述边界外，已授权范围内的本地启动、测试执行、截图、trace、精确清理和证据落盘应连续推进。

---

## 6. 自检

- [ ] 每条必测 journey 是否可追溯到验收标准。
- [ ] 是否优先复用了项目原生 runner 和命令。
- [ ] 是否区分可重复测试与探索性操作。
- [ ] 认证状态、日志和证据是否无秘密、无个人绝对路径。
- [ ] 测试数据是否隔离，清理是否只覆盖本次拥有的数据。
- [ ] verdict 是否与实际覆盖一致。
- [ ] `blocked`、`partial`、`waived` 是否暴露责任人、替代证据和剩余风险。

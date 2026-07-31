# TIC 0.3.0 E2E 验证标准化

## 背景

TIC 0.2.2 已要求 standard / critical 任务从验收标准推导测试或可观察验证，并在 UI 风险需要时使用真实界面工具。现状仍缺少统一的端到端验证契约：

- 总控没有明确判断何时必须进入 E2E 验证。
- 项目 adapter 没有记录 E2E 命令、环境、认证、数据、核心旅程和证据路径。
- Playwright Test、Playwright MCP、Browser、Chrome 和 Computer Use 之间缺少稳定的职责边界。
- 阻塞、豁免、清理和证据结论没有统一输出。

这会导致不同 Agent 对同一风险档位采用不同口径，或者只完成探索性点击而没有形成可重复、可审计的验证证据。

## 目标

在 0.3.0 增加工具中立、按风险触发的 E2E Verification Gate：

1. 新增 canonical `e2e-verification` Skill 和 Codex `tic-e2e-verification` wrapper。
2. 由 `tic-workflow-orchestrator` 在 Verification phase 条件路由该 Skill。
3. 在 `project-adapter.md` 增加保护性、可迁移的 `verification.e2e` 配置。
4. 统一环境、认证、测试数据、执行、证据、清理和 verdict 生命周期。
5. 保持 consulting / micro 轻量，不要求所有 UI 微改动运行完整 E2E。

## 非目标

- 不内置 Playwright、浏览器或 MCP 运行时，不替业务项目生成测试脚手架。
- 不把 Playwright MCP、Chrome DevTools MCP、Browser 或 Computer Use 绑定为唯一实现。
- 不把探索性操作自动等价为可重复的 CI E2E 通过。
- 不要求真实生产账号、生产写入、真实支付或不可逆数据清理。
- 不覆盖已有 `ai-harness/project-adapter.md`；schema 升级只允许保护性迁移。

## 核心决策

### 1. 风险触发

| 场景 | E2E 要求 |
| --- | --- |
| consulting | 不触发 |
| micro 且无行为变化 | 不触发；执行最小验证 |
| micro 且涉及局部交互 | 按验收标准做窄路径真实界面验证 |
| standard 且改变用户旅程、跨层交互或关键 API 流程 | 验证受影响的核心旅程 |
| critical，或涉及认证、权限、资金、隐私、迁移、跨服务关键链路 | E2E gate；无法执行时必须记录 blocked / waived、责任人、原因和剩余风险 |

仅出现“UI”“API”或“登录”关键词不自动要求全量套件；应按破坏性、影响面、可恢复性、外部副作用和验证成本判断受影响旅程。

### 2. 工具职责

优先级如下：

1. 项目已有可重复 E2E 套件和命令时，使用项目原生命令作为主要事实源。
2. Web 项目需要新增可重复 E2E 且项目未声明其他 runner 时，Playwright Test 是默认候选，不是强制依赖。
3. Playwright MCP、Browser、Chrome、Computer Use 和截图用于探索、调试、真实账号态或桌面/插件场景；除非验收明确允许可观察验证，否则不能单独替代可重复套件。
4. 无 UI 的服务链路使用项目原生 API、契约、集成或系统测试，不为了满足“E2E”名称强行引入浏览器。

### 3. 配置契约

项目 adapter 使用以下 schema。未知项保持 `待确认` 或空值，不伪造命令：

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

约束：

- `auth_state_path` 只能记录项目相对路径，不记录 Token、密码或个人绝对路径。
- `auth_state_policy=local-only` 表示认证状态必须 gitignored；它与实际 `auth_mode` 分离。
- `setup_command`、`cleanup_command` 为空时不推测或执行。
- 现有 adapter 的非占位值、自定义章节和未知扩展字段必须保留。

### 4. 验证生命周期

```text
acceptance criteria
  -> determine E2E requirement
  -> resolve adapter and project-native commands
  -> preflight environment/auth/data
  -> execute affected core journeys
  -> collect assertions/logs/screenshots/trace as applicable
  -> cleanup owned test data
  -> record verdict and remaining risk
```

允许的 verdict：

- `passed`：所有必测旅程通过且证据完整。
- `failed`：已执行但存在失败断言或阻断性错误。
- `blocked`：环境、账号、依赖或安全边界导致无法执行。
- `waived`：有明确责任人批准不执行，并记录原因、替代证据和风险。
- `partial`：仅部分旅程完成；不得表述为整体通过。

### 5. 自治与暂停

Agent 可连续执行范围内的本地、可逆步骤和非破坏性验证，不因 Planning、环境启动或证据落盘机械暂停。

必须暂停：

- 需要新凭据、验证码、人工登录或未授权账号。
- 目标为生产环境、真实资金、真实通知或外部不可逆写入。
- 清理范围不明确，可能删除非本次创建的数据。
- 多个环境或 runner 选择会实质改变成本、风险或结果。
- critical gate 需要豁免或降低验证范围。

## 验收标准

1. `Skills/e2e-verification.md` 存在并符合 `tic_skill.v1`，包含风险触发、工具职责、完整生命周期、安全边界、verdict 和输出格式。
2. `tic-workflow-orchestrator` 在 Verification phase 条件路由 `e2e-verification`，同时保持 route-only 和行数上限。
3. 模板 adapter、Shell bootstrap、PowerShell bootstrap 生成同一 `verification.e2e` schema。
4. `project-adapter-maintainer` 明确把 E2E 配置作为保护性迁移内容，并禁止记录秘密或个人绝对路径。
5. Codex wrapper 能从项目规则源解析并读取 canonical Skill；包装器本身不复制正文。
6. `manifest.json`、README、USAGE、自动化说明、项目 AGENTS 模板和全局 Loader 口径一致。
7. `tools/validate-pack.sh` 覆盖 Skill、路由、schema、wrapper、adapter 保留和安全边界回归。
8. `bash tools/validate-pack.sh`、`bash -n tools/*.sh`、`jq empty manifest.json` 和 `git diff --check` 通过。
9. 重复 refresh `AGENTS.md` marker 保持字节级幂等，并能清理旧 refresh 遗留的文件末尾空白行。

## 兼容与迁移

- 普通 install / refresh / update 继续逐字节保留已有 adapter。
- 新项目首次 bootstrap 获得 E2E 配置块。
- 老项目只有在显式调用 `project-adapter-maintainer(mode=migrate)` 时补齐缺失字段。
- 项目已有 E2E 约定优先；新 schema 不改变既有 runner、命令或证据路径。
- Shell / PowerShell marker refresh 只替换受管区块，不累积文件末尾空白行。

## 回滚

回滚本次规则、模板、wrapper、验证脚本和文档改动即可。已由业务项目维护的 adapter 不应被自动回滚或覆盖；若项目已显式迁移，可保留新增配置，或通过人工审阅删除未使用的空字段。

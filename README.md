# Team-Intelligence-Center

面向软件项目的轻量 AI 协作规则包：用一个小型 Workflow Core 约束动作边界，
用可独立选择的 Capability 承载调查、契约、验证、交接和项目记忆。

> Public preview：当前版本为 `0.5.3`。

## 0.5.3 的核心变化

TIC 不再用一个综合模式同时决定计划、风险和验证。默认行为变成：

1. 普通、可逆、本地工作直接执行；
2. 规划、授权、验证、Review 和事实持久化分别判断；
3. Superpowers 等外部 Skills 只作为按需方法库；
4. OpenSpec 只承载需要长期维护的规格事实；
5. Skill 是独立能力，不是固定流水线节点，wrapper 只按精确事实触发；
6. 没有新鲜验证证据不得声称完成；
7. 每次交付做 diff 自审，高影响变更按需独立 Review。

0.5.3 修复 0.5.2 试运行暴露的产品链缺口：普通任务仍直接执行；大型新产品、
业务域或重大用户旅程在缺少已确认产品基线时，先形成 PRD 草稿和 UI/旅程基线。
确认前只做调查、原型和可逆技术探针，不让 API、Schema、菜单或领域模型反向
定义需求。PRD Author、PRD Review 和开发后 PRD Sync 各自承担独立责任。

权威定义见：

- [`Workflow/core.md`](Workflow/core.md)
- [`Workflow/capability-schema.md`](Workflow/capability-schema.md)
- [`Workflow/scenarios.json`](Workflow/scenarios.json)
- [`Global-Rules/git-rules.md`](Global-Rules/git-rules.md)

设计说明见
[`docs/sdd/tic-0.5.3-product-baseline-prd-workflow.md`](docs/sdd/tic-0.5.3-product-baseline-prd-workflow.md)。

## 五个独立维度

| 维度 | 可选策略 |
| --- | --- |
| 规划深度 | inline / brief / living |
| 执行授权 | autonomous / confirmation-required |
| 验证范围 | targeted / integration / e2e / operational |
| Review | self / independent / user-decision |
| 事实持久化 | task-context / OpenSpec / PRD / Runbook / Release / local candidate |

## Capability 模型

`Skills/` 下每个能力都使用 `tic_capability.v1` 声明：

- 何时使用、何时不使用；
- 是否产生外部副作用；
- 默认是否创建产物；
- 所需前置事实；
- 相关但不会自动调用的能力。

常用能力包括：

| 能力 | 用途 |
| --- | --- |
| `prd-author` | 新产品、重大旅程或显式 PRD 请求需要形成可确认产品基线时使用 |
| `prd-review-checklist` | 产品 owner 审查 PRD 是否足以支持正式实现时使用 |
| `code-investigator` | 用户要求追踪现有行为，或关键未知事实阻塞当前决策时调查 |
| `contract-handoff` | 共享契约跨实现边界且存在独立消费者时对齐语义 |
| `shared-domain-arbiter` | 并发 owner 在同一共享域发生真实冲突时裁决 ownership |
| `e2e-verification` | 局部检查不足以证明关键旅程时补充端到端证据 |
| `delivery-walkthrough` | 为明确的异步 review、QA 或使用者生成走查材料 |
| `post-dev-prd-sync` | 同步已批准且已交付行为；未批准的规格漂移只报告、不反写 PRD |
| `release-handoff` | 独立发布消费者需要部署、验证、监控或回滚信息时使用 |
| `collaboration-memory-maintainer` | 显式维护可确认、可过期、可审计的协作记忆 |

`tic-workflow-orchestrator` 仅保留为复杂规划和旧版迁移的兼容能力，不是普通
任务入口。

## 快速安装

先预览，再应用到业务项目：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --preview \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project

bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --rules-dir /path/to/Team-Intelligence-Center \
  /path/to/project
```

安装器会生成轻量入口、工具规则、项目适配文件和 memory 骨架。普通刷新会
保留已有 `ai-harness/project-adapter.md`、共享 memory 和项目自定义内容。
只有显式传入 `--regenerate-adapter` 才会备份并重建 adapter。

可选安装 Codex 全局 Loader：

```bash
bash /path/to/Team-Intelligence-Center/tools/install-codex-global.sh \
  --dry-run \
  --rules-dir /path/to/Team-Intelligence-Center
```

Loader 只负责发现项目规则和提供 `tic-*` wrapper，不复制规则本体，也不
覆盖项目级决策。

完整安装、更新和目录说明见 [`USAGE.md`](USAGE.md) 与
[`docs/automation.md`](docs/automation.md)。

## 项目接入后的边界

- 项目 `AGENTS.md` 和 `ai-harness/project-adapter.md` 优先于通用模板。
- 普通任务不需要先调用 Orchestrator。
- 普通任务不默认创建 PRD；大型新产品或重大用户旅程缺少产品基线时先生成草稿。
- 不默认创建 SDD、Walkthrough、Release Handoff 或 session artifact。
- 不默认检索、提取或晋升 Collaboration Memory。
- 不默认执行 Git 分支、提交、push、merge、tag 或发布。
- Git 写操作获授权后使用统一类型分支、必填具体 scope 的中文 Conventional
  Commit，并在写入前通过分支名和提交信息校验器。
- 不默认安装 Git hooks、CodeGraph、浏览器 runner 或供应商工具。
- UI 和关键旅程只在结论需要时使用真实界面或 E2E 证据。

## Collaboration Memory

共享事实、决策、runbook 和团队约定位于 `ai-harness/memory/`；个人偏好和
待确认候选位于 gitignored 的 `.tic/local/`。它保存可复用结论，不保存原始
聊天、密钥、认证状态或未经确认的敏感推断。

读取、提取、晋升、冲突处理和过期审计都必须通过显式请求或已确认的项目
约定触发。Memory 不替代代码、PRD、规格、测试和当前外部状态。

## 发布记录

`0.1.0`、`0.2.0`、`0.2.1` 的历史记录均保存在
[`docs/releases`](docs/releases)。

`0.2.2`、`0.3.0`、`0.5.0`、`0.5.1`、`0.5.2` 已归档，当前版本为 `0.5.3`。

0.4.0 从未作为公开版本发布；其开发中的 Collaboration Memory 工作已合并
到 0.5.0，不保留虚构的发布记录。

当前开发证据见
[`docs/releases/0.5.3`](docs/releases/0.5.3) 和
[`docs/test-evidence/tic-0.5.3`](docs/test-evidence/tic-0.5.3)。

## 验证

```bash
bash tools/validate-pack.sh
```

验证器覆盖版本一致性、Workflow 场景、Capability 契约、安装幂等、
Project Adapter 与共享 memory 保留、全局 wrapper、Git 建议只读边界及
分支名/提交信息校验器、Shell fixture。若本机存在 PowerShell，也会运行
等价 fixture。

## 开源与贡献

项目使用 Apache-2.0 License。贡献前请阅读
[`CONTRIBUTING.md`](CONTRIBUTING.md) 和 [`SECURITY.md`](SECURITY.md)。

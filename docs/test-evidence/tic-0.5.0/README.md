# TIC 0.5.0 Workflow Core 验证证据

- 变更：`tic-0.5.0-workflow-core`
- 分支：`feature/collaboration-intelligence-loop`
- 日期：2026-08-07
- runner：项目原生 `tools/validate-pack.sh`
- 状态：本地实现验证通过，尚未 commit、tag、push 或发布

## 验收映射

| 验收项 | 验证方式 | 结果 |
| --- | --- | --- |
| 默认模式 | Core + 场景断言 | `direct` |
| 动作级升级 | shared API、生产迁移、Git push 场景 | passed |
| 验证独立性 | 方向明确但需要 E2E 的关键旅程仍为 `direct` | passed |
| Capability 契约 | 23 个 Skill 检查 `tic_capability.v1` | 23/23 |
| 无 metadata 自动级联 | 禁止 `risk_min` / `delegates_to` | passed |
| Orchestrator 边界 | compatibility、非默认入口、217/240 行 | passed |
| Bootstrap 内聚性 | 禁止安装 OpenSpec、Superpowers 或执行 Git 接入 | passed |
| Contract 低耦合 | 只有共享契约跨边界协调时启用 | passed |
| shared memory 首次创建 | 隔离 bootstrap fixture | passed |
| shared memory refresh 保留 | sentinel + checksum，连续两次 force | passed |
| Project Adapter 保留 | refresh 前后 checksum | passed |
| 本地画像保持 gitignored | `.gitignore` 与未自动创建断言 | passed |
| Codex wrapper | 15 个 wrapper quick validation | 15/15 |
| Codex Loader 渲染 | 隔离安装 fixture，版本 0.5.0 | passed |
| PowerShell runtime | 条件 fixture | partial：当前环境无 `pwsh` |

## Red / Green 证据

实现前先在 `tools/validate-pack.sh` 加入 Workflow、Capability、版本迁移、
Memory 与保留性断言，分别观察到缺失文件、旧契约和旧模板失败。

最终自审又补了三条针对性回归：

1. Bootstrap 内聚性断言先失败 1 项；正文仍会安装外部 workflow 系统。
2. 场景语义断言先失败 1 项；E2E 必要性仍错误抬高执行模式。
3. Contract 激活断言先失败 1 项；API 或 FE/BE 关键词仍会自动触发门禁。

每项都在观察到预期失败后修改实现，并由最终完整 validator 重新证明。

## 最终命令

| 命令 / 方法 | Exit code | 结果 |
| --- | ---: | --- |
| `bash -n tools/bootstrap-project.sh tools/install.sh tools/update.sh tools/install-codex-global.sh tools/codegraph-helper.sh tools/git-advice.sh tools/validate-pack.sh` | 0 | Shell 语法通过 |
| `jq empty manifest.json Workflow/scenarios.json` | 0 | JSON 合法 |
| `python3 -m json.tool manifest.json` | 0 | manifest 合法 |
| `python3 -m json.tool Workflow/scenarios.json` | 0 | 场景 JSON 合法 |
| `git diff --check` | 0 | 已跟踪 diff 无空白错误 |
| untracked 文件尾随空白扫描 | 0 | 无尾随空白 |
| `quick_validate.py templates/codex-global/skills/*` | 0 | 15/15 wrapper 合法 |
| active legacy policy `rg` 扫描 | 0 | 0 个活动策略命中 |
| `bash tools/validate-pack.sh` | 0 | `Validation passed.`，0 failure，1 warning |

## Validator 覆盖

最终 validator 证明：

- 版本、manifest、README、Changelog 和 0.5.0 目录一致；
- 0.4.0 未作为公开版本保留，未发布 memory 工作迁入 0.5.0；
- 三模式和七个场景的 mode、checkpoint、Capability 与关键 artifact
  期望一致；
- 23 个 Skill 均满足 Capability schema；
- 普通项目模板不要求 Orchestrator、默认 Memory 或 mode-wide artifact；
- Bootstrap 不安装外部 workflow 系统；
- Contract Handoff 不因 API 关键词自动触发；
- Shell fixture 首次创建五个 shared memory 文件；
- 注入 sentinel 后连续刷新，shared memory checksum 不变；
- 既有 Project Adapter 逐字节保留，显式 regenerate 会先备份；
- 全局 Loader 能渲染 0.5.0 和 memory wrapper；
- Git advice 保持只读，分支和 tag 门禁仍存在。

## 历史试运行证据

未发布的 Collaboration Memory 实现曾在一个父工作区和七个正式子项目进行
本地刷新，验证 adapter 与既有 memory 保留。该记录只作为 memory 实现的
历史试运行证据，本次没有重新操作这些业务项目，也不把它描述为 0.5.0
Workflow Core 的新鲜 E2E 结果。

## 未覆盖与剩余风险

- 当前环境没有 `pwsh`。验证器检查 PowerShell 静态契约，并在检测到
  `pwsh` 时自动运行创建、gitignore 和 sentinel 保留 fixture；本次
  PowerShell runtime 状态为 `partial`。
- 本仓库没有业务 UI、真实生产环境或真实外部系统；这些能力的产品级 E2E
  不属于规则包本地验证范围。
- 本次未执行 Git 分支创建、提交、push、merge、tag 或发布。

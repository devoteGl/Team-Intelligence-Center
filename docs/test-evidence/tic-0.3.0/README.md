# TIC 0.3.0 E2E 标准化验证证据

- 验证日期：2026-07-30
- 变更：`tic-0.3.0-e2e-verification-standardization`
- 分支：`feature/e2e-verification-standardization`
- 环境：macOS / zsh，规则包 Shell 验证使用系统 Bash

## E2E requirement

```yaml
e2e_requirement:
  decision: targeted
  reason: "本仓库是规则与安装自动化包，不提供可运行的业务 UI；需要验证规则路由、adapter 生成、旧文件保留和 Codex wrapper 安装链"
  affected_journeys:
    - "新项目首次 bootstrap 获得 verification.e2e schema"
    - "已有 project-adapter 在普通 refresh 中逐字节保持不变"
    - "显式 regenerate 生成新 schema 并备份旧文件"
    - "Codex 全局安装器发布 tic-e2e-verification wrapper"
    - "AGENTS marker refresh 重复执行保持字节级幂等"
```

主要事实源是项目原生 `tools/validate-pack.sh` 和隔离临时目录 fixture。浏览器 E2E 不适用，本次没有业务页面、账号态或运行时服务。

## 已执行

| 验证项 | 命令 / 方法 | 结果 | 覆盖 |
| --- | --- | --- | --- |
| 规则包回归 | `bash tools/validate-pack.sh` | 通过 | Skill contract、路由、schema、wrapper、adapter 保留、显式重生成、更新链 |
| Shell 语法 | `bash -n tools/*.sh` | 通过 | 所有 Shell 工具 |
| manifest | `jq empty manifest.json` | 通过 | JSON 语法 |
| diff 格式 | `git diff --check` | 通过 | 空白与补丁格式 |
| Codex Skill 结构 | `quick_validate.py templates/codex-global/skills/tic-e2e-verification` | 通过 | wrapper frontmatter 与结构 |
| Codex 临时安装 | `install-codex-global.sh --yes --codex-home <temp>` + 文件/路由断言 | 通过 | wrapper 实际分发 |
| adapter 默认保留 | 临时 adapter 执行 bootstrap `--force` 前后比较 `cksum` | 通过 | 旧 adapter 逐字节保留 |
| adapter 显式重生成 | 临时 workspace 执行 `--regenerate-adapter` | 通过 | 备份、workspace 识别、E2E schema |
| marker 幂等 | 临时项目连续 refresh，并注入旧版尾部空行后复测 | 通过 | 重复写入字节级不变、旧空行可自愈 |
| 真实工作区接入烟测 | 父工作区 + 7 个已接入子项目执行本地 0.3.0 refresh | 通过 | lock 解析、adapter 保留、子模块隔离、受管文件格式 |

## Verdict

```yaml
e2e_verification:
  requirement: targeted
  runner: project-native
  environment: local-isolated-fixtures
  verdict: passed
  evidence_root: docs/test-evidence/tic-0.3.0
  cleanup: "所有 fixture 位于 mktemp 目录，由验证器精确删除"
```

## 逻辑 review

本地 review 覆盖：

- 首轮发现 `auth_mode: local-only` 混淆认证方式与安全策略、未知 `data_strategy` 被写成事实；已改为 `auth_mode` / `data_strategy` 待确认，并新增独立 `auth_state_policy: local-only`。
- 真实工作区首轮 refresh 发现 `AGENTS.md` marker 在文件末尾累积空白行；已修正 Shell / PowerShell 替换逻辑，并以临时 fixture 和 8 个真实接入点复测。
- `policy=disabled` 不得被解释为通过；critical gate 只能阻塞或由有权责任人豁免。
- 项目原生可重复套件优先，Playwright Test 只作为未指定 runner 时的 Web 候选。
- MCP、Browser、Chrome 和 Computer Use 不作为默认唯一事实源。
- 认证状态只记录 gitignored 的项目相对路径，证据需要脱敏。
- 清理只作用于本次验证拥有的数据。
- `partial`、`blocked`、`waived` 不得冒充 `passed`。
- Release Handoff 和 Walkthrough 能接收 E2E verdict 与证据。

修正后复核结论：未发现剩余 CRITICAL、HIGH、MEDIUM 或 LOW 问题，建议 `APPROVE`。

## 未执行

| 验证项 | 原因 | 剩余风险 | 建议 |
| --- | --- | --- | --- |
| PowerShell 运行时解析和行为 fixture | 当前环境没有 `pwsh` | Windows here-string、编码或运行时差异 | 在 Windows / pwsh CI 运行 bootstrap fixture |
| 业务应用浏览器 E2E | 本仓库没有业务 UI、服务或账号态 | 无法证明某个业务项目的具体旅程 | 由业务项目按新 Skill 和 adapter 配置执行 |
| release / tag / stable 更新 | 尚未得到发版 Git 操作授权 | 0.3.0 尚未进入 stable 通道 | 用户确认后按 `git-flow-operator` 执行并回填证据 |

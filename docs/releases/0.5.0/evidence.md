# 0.5.0 本地开发证据

## Git 状态

- 开发分支：`feature/collaboration-intelligence-loop`
- 基线：已发布 `0.3.0`
- 候选 tag：`0.5.0`，尚未创建
- commit / push / merge / tag / 发布：未授权，均未执行

## 新鲜验证

2026-08-07 在规则包根目录执行：

| 证据 | 结果 |
| --- | --- |
| Shell 语法检查 | exit 0 |
| manifest 与场景 JSON 双解析 | exit 0 |
| `git diff --check` 与 untracked 空白扫描 | exit 0 |
| 15 个 Codex wrapper quick validation | 15/15 |
| 活动旧语义扫描 | 0 命中 |
| `bash tools/validate-pack.sh` | exit 0，0 failure，1 warning |

唯一 warning 是当前环境没有 `pwsh`，因此 PowerShell runtime fixture 为
`partial`；不得描述为已运行通过。

完整命令、验收映射和未覆盖项见
`docs/test-evidence/tic-0.5.0/README.md`。

## 自审修正

最终 review 没有只依赖 validator 的既有绿灯，而是补充并先观察失败的回归
断言，修正：

1. `project-governance-bootstrap` 仍会安装外部 workflow 系统；
2. 关键旅程需要 E2E 时错误进入 `structured`；
3. `contract-handoff` 仍会被 API / FE/BE 关键词自动触发。

修正后完整验证器重新通过。

## Collaboration Memory 保留性

Shell 隔离 fixture 证明：

- 新项目创建五个 shared memory 文件；
- `.tic/local/` 被 gitignore，但个人文件不自动创建；
- 注入 sentinel 后连续两次 refresh，memory checksum 不变；
- 既有 Project Adapter 逐字节保留；
- 显式 regenerate adapter 会先备份。

此前一个父工作区和七个子项目的本地 memory 试运行证据继续保留，但本次未
重新修改这些业务项目，不把历史试运行当作新鲜 Workflow Core 结果。

## 发布边界

本地实现和规则包验证不等于公开发布。创建 release 分支、commit、tag、
push、合并或更新 stable 通道仍需要用户另行授权。

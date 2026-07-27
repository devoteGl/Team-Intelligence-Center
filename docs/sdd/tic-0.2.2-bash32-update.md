# TIC 0.2.2：Bash 3.2 一键更新兼容修复

## 问题

0.2.1 的 `tools/update.sh` 在 `set -u` 下始终展开
`"${CODEX_HOME_ARG[@]}"`。macOS 自带 GNU Bash 3.2 将未填充的数组视为
未绑定变量，导致默认 preview 和普通应用路径在刷新 Codex 全局 Loader
之前退出。

显式传入 `--codex-home` 时数组非空，因此不会触发该错误。PowerShell
更新器使用不同的参数构造，不受该 Shell 缺陷影响。

## 目标

- 默认不传 `--codex-home` 时，preview 和普通应用路径均能刷新全局 Loader。
- 显式 `--codex-home <path>` 仍按原值透传。
- 回归测试不写入真实 Codex 目录，也不递归执行规则包校验。
- 不改变 stable/current/ref 选择、项目刷新或 adapter 保护行为。

## 非目标

- 不重构 PowerShell 更新器。
- 不改变 Codex home 的默认解析规则。
- 不修改 Project Adapter schema 或生成逻辑。
- 不移动已经发布的 `0.2.1` tag。

## 行为规格

`tools/update.sh` 使用空字符串保存可选 Codex home，由单一刷新函数决定：

1. 路径为空时，只向 `install-codex-global.sh` 传安装模式和规则目录。
2. 路径非空时，再追加 `--codex-home <path>`。
3. preview 使用 `--dry-run`，apply 使用 `--yes`。
4. 两条路径都不展开空数组。

## 验收标准

- 当前版本为 `0.2.2`，manifest 与 VERSION 一致。
- macOS Bash 3.2 下，隔离的默认 preview 成功。
- macOS Bash 3.2 下，隔离的默认 apply 成功且参数准确。
- 显式 Codex home 被完整透传。
- `bash -n tools/*.sh`、`jq empty manifest.json`、`git diff --check` 通过。
- `bash tools/validate-pack.sh` 输出 `Validation passed.`。
- 发布后 stable 通道选择 `0.2.2`，父子项目 lock 更新且已有 adapter 不变。

## 回滚

- 规则仓库回滚目标为 `0.2.1`。
- 0.2.1 默认更新存在已知问题，回滚后必须显式传入 `--codex-home`，
  或用 `--no-global` 后单独刷新全局 Loader。
- 本修复不涉及数据、生产配置或不可逆迁移。

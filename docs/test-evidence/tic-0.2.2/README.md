# TIC 0.2.2 验证证据

- 验证日期：2026-07-27
- 运行时：macOS GNU Bash `3.2.57`
- 范围：默认全局刷新、显式 Codex home、Shell 语法、规则包一致性

## TDD 红灯

在实现修复前加入隔离回归，执行 `bash tools/validate-pack.sh`：

- 默认 preview 在 `tools/update.sh` 的空数组展开处报
  `CODEX_HOME_ARG[@]: unbound variable`。
- 验证器最终报告 1 个失败，退出码为 `1`。
- 其余规则包检查通过。

## TDD 绿灯

实现改为标量路径和单一刷新函数后，同一隔离回归覆盖：

- 默认 preview。
- 默认 apply，并比对全局安装器参数。
- 显式 `--codex-home <path>` apply，并比对路径透传。
- 临时规则包使用 stub 校验器和 stub 安装器，不写入真实 Codex 目录。

`bash tools/validate-pack.sh` 已输出 `Validation passed.`。

## 独立代码审查

- reviewer 审查 14 个变更与新增文件，并核对全局安装器上下文。
- 首轮发现 2 个发布记录状态不一致，修复后完成复核。
- 最终 CRITICAL/HIGH/MEDIUM/LOW 均为 0，结论为 `APPROVE`。

## 最终验证

```bash
bash -n tools/*.sh
jq empty manifest.json
git diff --check
bash tools/validate-pack.sh
```

上述命令在 hotfix、`master` 发布合并和 develop 回灌树上均已通过。

## 发布后验证

- 远端 stable tag 为 `0.2.2`。
- 从 0.2.1 使用一次性显式 `--codex-home` 参数成功切换到 0.2.2。
- 0.2.2 默认 preview 和默认 apply 均未传 `--codex-home`，结果通过。
- 父项目和 8 个子项目 lock 全部为 `0.2.2`。
- 9 个 Project Adapter 更新前后 SHA-256 全部一致。
- Codex 全局 Loader 规则版本为 `0.2.2`。

## 未测项

- 当前环境没有 `pwsh`，PowerShell 运行时仍记为未测。
- 本次未修改 PowerShell 更新器，其静态结构校验继续由规则包验证覆盖。

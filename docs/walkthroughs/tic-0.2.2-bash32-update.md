# TIC 0.2.2 Bash 3.2 更新兼容修复 - Delivery Walkthrough

## 交付摘要

- 0.2.1 的 Project Adapter 保护逻辑保持不变。
- 修复默认一键更新在 macOS Bash 3.2 下的空数组错误。
- 回归测试在隔离临时规则包中执行，不触碰真实 Codex 目录。

## 实现走查

旧路径把可选参数保存为数组，并无条件展开：

```text
空 CODEX_HOME_ARG
  -> set -u + Bash 3.2
  -> unbound variable
  -> 全局 Loader 和项目刷新均未执行
```

新路径使用一个可选标量：

```text
CODEX_HOME_PATH
  -> refresh_codex_global
     -> 空：只传 mode + rules-dir
     -> 非空：追加 --codex-home + path
```

## 变更范围

| 文件 | 作用 |
| --- | --- |
| `tools/update.sh` | 移除空数组展开，集中构造全局刷新命令 |
| `tools/validate-pack.sh` | 增加 Bash 3.2 隔离行为回归 |
| `VERSION`、`manifest.json`、`CHANGELOG.md` | 登记 0.2.2 |
| `docs/`、README、USAGE | 规格、证据、交接和当前版本说明 |

## Review 指引

- 检查 `refresh_codex_global` 是否只负责全局 Loader 命令构造。
- 检查空路径不会产生空参数，显式路径不会被拆词。
- 检查 regression fixture 不调用真实规则包校验器或真实全局安装器。
- 检查 stable/current/ref、项目刷新和 adapter 逻辑没有被改动。

## 风险与回滚

- 剩余风险：当前环境缺少 PowerShell 运行时；本次未改 PowerShell。
- 回滚目标：`0.2.1`，但需使用其已知规避参数完成更新。
- 不涉及业务数据、数据库、权限、生产配置或不可逆操作。

## 发布收口

独立 reviewer 最终审查 14 个文件，所有严重级别问题均为 0，结论为
`APPROVE`。

最终 tag、远端、develop 回灌、stable 冒烟、父子项目 lock 和 adapter
校验和写入 `docs/releases/0.2.2/evidence.md`。

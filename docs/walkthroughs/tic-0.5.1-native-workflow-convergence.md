# TIC 0.5.1 交付走查

## 为什么改

0.5.0 已取消默认 Orchestrator，但三种模式仍混合规划、授权和验证；外部
umbrella Skills 也可能重新引入固定流水线。

## 改了什么

- Workflow Core 改为五个独立维度。
- 项目与全局入口改为 outcome-driven 原生执行。
- Superpowers 降为按需方法，OpenSpec 限定为长期事实源。
- 验证成为持续证据线，Review 按对象触发。
- 旧版 CP 和任务档位改为迁移输入。

## 如何验证

运行 `bash tools/validate-pack.sh`，并在业务项目 refresh 前预演安装计划。

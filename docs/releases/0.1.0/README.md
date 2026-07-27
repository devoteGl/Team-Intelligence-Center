# 0.1.0 归档记录

- 状态：已归档，public preview
- 归档日期：2026-07-27
- Git 提交：`d8fe814ad633bd06d6ead7815ad8f7d6d3db5324`
- 提交摘要：`fix(git-flow): 补齐远端分支门禁`
- 发布 tag：未创建
- 后续版本：`0.2.0`

## 归档说明

`0.1.0` 的源码事实源是上述 Git 提交。本目录只保存版本元数据和升级入口，不复制整仓源码，避免两份规则正文发生漂移。

如需恢复该版本，优先使用后续发布的 `0.1.0` tag；tag 尚未创建时可使用归档提交：

```bash
git checkout --detach d8fe814ad633bd06d6ead7815ad8f7d6d3db5324
```

该命令会改变规则库工作树，应在无未提交改动时执行。业务项目通过 submodule 引入时，还需要审阅并提交父项目的 submodule 指针。

## 主要能力

- single adaptive workflow 与 `risk_floor`
- SDD / TDD、OpenSpec 与 Superpowers 分层
- 契约冻结、共享文件域仲裁
- 多 Agent 会话 artifact 协议
- 交付 Walkthrough、PRD 草稿和 Release Handoff
- 轻量 bootstrap、Codex 全局 loader 和一键更新入口

## 已知限制

- 阶段检查点过于刚性，普通任务可能产生不必要的等待。
- 复杂度乘法分容易把普通接口调整升级为 critical。
- 更新脚本跟随当前分支，不能明确区分稳定版、开发版和锁定版本。
- 包版本使用标准 SemVer，但 Git Flow 文档要求三位补零补丁号，存在格式冲突。


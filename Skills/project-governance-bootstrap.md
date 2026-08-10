---
schema: tic_capability.v1
id: project-governance-bootstrap
status: canonical
category: setup
activation:
  when:
    - 用户要求项目接入、修复或更新 TIC 轻量入口
  not_when:
    - 项目未请求接入 TIC
    - 只是普通开发任务
side_effects: local-reversible
artifacts:
  default: project-entrypoints
  when_needed:
    - 项目需要 loader、lock、adapter 或工具规则入口
requires: []
related:
  - project-adapter-maintainer
---

# Project Governance Bootstrap（项目接入能力）

## 技能用途

只接入 TIC 轻量入口，并保存项目原有规则。它不安装 OpenSpec、Superpowers、
CodeGraph 或其他方法库，也不把全部 TIC Skills 复制到业务项目。

## 方法

1. 识别项目根、父子工作区、现有 `AGENTS.md`、adapter、memory 和自定义规则。
2. 预览 `tools/bootstrap-project.sh` 或 PowerShell 对应脚本将产生的变化。
3. 使用 marker 有界合并 loader，写入项目相对 `.tic-rules.lock`；机器绝对路径
   只进入 gitignored `.tic-rules.local`。
4. 缺失时创建最小 adapter 和工具入口；已有非占位内容默认保留。
5. 运行安装后验证，报告新增、更新、保留和无法判断的内容。

## 边界

- 不覆盖 adapter、memory、自定义段落或未提交变更。
- 不自动创建分支、提交、push、tag、依赖安装或外部写入。
- 父子工作区分别解析自己的 lock 与 adapter，规则源可共享，项目事实不共享。
- 安装动作的授权仍由用户请求决定；只读审计可直接执行。

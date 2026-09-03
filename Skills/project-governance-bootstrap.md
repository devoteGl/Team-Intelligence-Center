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
   只进入 gitignored `.tic-rules.local`。外部规则源以
   `rules_source=local_config` 声明分支无关的本机覆盖。
4. 识别旧版 TIC 复制到项目 `.codex/skills/` 的宽触发 Skill；仅对已知签名
   先备份再移除，未知内容和项目自定义 Skill 保留。
5. 缺失时创建最小 adapter 和工具入口；已有非占位内容默认保留。
6. 运行安装后验证有效规则版本和残留 Skill，报告新增、更新、保留及无法判断
   的内容。

## 边界

- 不覆盖 adapter、memory、自定义段落或未提交变更。
- 不自动创建分支、提交、push、tag、依赖安装或外部写入。
- 父子工作区分别解析自己的 lock 与 adapter，规则源可共享，项目事实不共享。
- tracked 入口修改在提交前可能被 stash 或 checkout 撤回；安装结果必须报告该
  Git 状态，不把“已写入当前工作树”表述为“所有分支已永久升级”。
- 安装动作的授权仍由用户请求决定；只读审计可直接执行。

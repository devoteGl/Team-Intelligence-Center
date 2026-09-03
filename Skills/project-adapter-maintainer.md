---
schema: tic_capability.v1
id: project-adapter-maintainer
status: canonical
category: setup
activation:
  when:
    - 用户要求创建、补全、审计、迁移或修复 project adapter
    - adapter 与已确认项目事实冲突并影响当前工作
  not_when:
    - adapter 已足够支撑当前任务
    - 仅因为发现新代码或技术栈关键词
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - ai-harness/project-adapter.md 的最小变更
requires: []
related:
  - code-investigator
  - project-governance-bootstrap
---

# Project Adapter Maintainer（项目适配维护能力）

## 技能用途

维护项目自己的命令、边界、artifact owner、验证和 Git 政策。adapter 是项目
事实的索引，不是比代码、CI 和用户确认更新的权威真相。

## 事实优先级

1. 用户在当前任务明确确认的项目事实；
2. 可运行配置、CI、脚本、仓库结构和当前验证证据；
3. 项目规则与维护者文档；
4. 现有 adapter；
5. 模板默认值。

冲突时保留旧值并标记待确认，除非更高优先级证据足以修正。

## 方法

1. 选择 `create | enrich | audit | migrate | repair`，写清本次目标字段。
2. 只读取证明这些字段所需的文件；需要深查代码时，再单独判断是否使用代码
   调查方法，不自动级联。
3. 生成字段级 diff：`preserve | add | update | unresolved`。
4. 保留未知自定义段落、注释、ownership、memory 和非占位值。
5. 禁止写入 secret、token、个人绝对路径、临时端口或未经验证的命令。
6. 更新后用项目真实命令或结构核对关键字段。

常见字段包括项目根、子项目、build/test/lint、E2E runner 与安全数据策略、
artifact roots、PRD owner、Git profile、权威 remote、受保护分支、commit
message、分支/tag/回灌政策及发布登记位置；只维护项目实际使用的部分。Git
字段缺失时先与 `Global-Rules/git-rules.md` 对照，不从当前所在分支反推政策。

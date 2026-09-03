---
schema: tic_capability.v1
id: git-flow-operator
status: canonical
category: protected-action
activation:
  when:
    - 用户要求创建、合并、推送、tag、回灌或发布 Git 引用
    - 项目政策要求为这些受保护动作生成可核对方案
  not_when:
    - 只读取 status、diff、log、show 或其他仓库事实
    - 普通本地代码修改、测试或 review
side_effects: external-write
artifacts:
  default: none
  when_needed:
    - 发布审计或异步执行需要 Git 操作记录
requires: []
related:
  - release-handoff
---

# Git Flow Operator（Git 受保护动作能力）

## 技能用途

在执行 branch、merge、push、tag、back-merge 等动作前解析项目真实 Git 政策、
目标引用和授权范围。规划或执行任何 Git 写操作时，必须先读取
`Global-Rules/git-rules.md`；项目 adapter 可以声明经过确认的例外。

## 解析顺序

1. 用户明确要求和当前任务授权。
2. 项目 `AGENTS.md`、adapter、贡献文档和发布政策。
3. 当前 refs、tracking、remote、tag 与工作树事实。
4. 没有项目政策时使用 `Global-Rules/git-rules.md` 的 `tic-gitflow-v1`，不得
   根据当前所在分支临时发明流程。

## 标准化门禁

- 普通任务不得直接在 `master`、`develop` 上提交或推送；已有任务改动位于
  长期分支时，先按标准迁移到类型分支。基线落后、分叉或改动混杂时请求决定。
- 分支创建前运行 `tools/validate-branch-name.sh` 或 PowerShell 等价脚本。
- commit 前使用显式路径暂存，核对完整 staged diff，并运行
  `tools/validate-commit-msg.sh` 或 PowerShell 等价脚本。
- commit message 使用必填、具体 scope 的中文 Conventional Commits；不得用
  缺 scope、泛化 `project` scope、英文 subject 或 `merge(...)` 类型绕过。
- 默认禁止 force push。例外只允许在用户明确授权具体任务 ref 后使用
  `--force-with-lease`，且长期分支与已发布 tag 不适用。
- submodule 按“子仓提交推送 → 父仓任务分支更新指针 → 父仓兼容性验证”执行，
  不得为改写子仓 commit message 生成新的 submodule 指针提交。

## 安全执行

- 先解析 authoritative remote、base、target、tag 和待推送 ref；禁止把模糊
  glob 或未解析变量用于写操作。
- 创建分支前，执行 `git fetch <authoritative-remote> --prune --tags`，核对基线新鲜度以及
  `refs/heads/<branch>`、`refs/remotes/<remote>/<branch>` 是否已存在或分叉。
- 写操作前展示或内部核对目标与影响。用户已在当前任务明确授权该结果，且
  目标可唯一、安全解析时，该授权已经充分，不再等待用户确认同一动作。
- 若远端、目标 ref、版本、覆盖行为无法唯一确定，或动作超出既有授权，暂停
  并请求补充决定。
- 已存在或已 push 的 tag 遵循 `preserve-existing`，不得静默移动或覆盖。
- 项目使用 `tic-gitflow-v1` 时，release/hotfix tag 为无 `v` 前缀、三位补零
  版本的 annotated tag；历史例外不自动重写。
- 每一步后用 `status`、`show-ref`、`merge-base`、远端 refs 等读取证据验证。

## 发布收口

项目要求 release/hotfix tag 后回灌时，继续记录项目集成分支回灌状态和项目要求的发布证据；回灌未完成、被明确豁免或由其他 owner 接手前，不声称整个发布
闭环完成。没有回灌政策的项目不发明该步骤。

Git 操作不会自动触发规格、PRD、walkthrough 或 release handoff；这些能力按
各自消费者和激活事实独立判断。

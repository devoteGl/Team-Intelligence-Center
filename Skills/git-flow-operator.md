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
目标引用和授权范围。它不强制所有项目采用 Git Flow。

## 解析顺序

1. 用户明确要求和当前任务授权。
2. 项目 `AGENTS.md`、adapter、贡献文档和发布政策。
3. 当前 refs、tracking、remote、tag 与工作树事实。
4. 没有项目政策时才使用最小默认：业务分支 `feature/<business-slug>`、版本
   使用 SemVer、tag policy 为 `preserve-existing`。

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
- 每一步后用 `status`、`show-ref`、`merge-base`、远端 refs 等读取证据验证。

## 发布收口

项目要求 release/hotfix tag 后回灌时，继续记录项目集成分支回灌状态和项目要求的发布证据；回灌未完成、被明确豁免或由其他 owner 接手前，不声称整个发布
闭环完成。没有回灌政策的项目不发明该步骤。

Git 操作不会自动触发规格、PRD、walkthrough 或 release handoff；这些能力按
各自消费者和激活事实独立判断。

---
schema: tic_capability.v1
id: release-handoff
status: canonical
category: handoff
activation:
  when:
    - 变更需要由独立发布、运维、QA 或使用方部署、观察、回滚或接手
    - 多个变更组成一个需要统一发布边界的 release train
  not_when:
    - 本地交付无需部署或独立接手
    - 仅因为创建了提交、分支或 tag
side_effects: local-reversible
artifacts:
  default: none
  when_needed:
    - 发布消费者或审计要求持久交接记录
requires: []
related:
  - e2e-verification
  - git-flow-operator
  - delivery-walkthrough
---

# Release Handoff（发布交接能力）

## 技能用途

把可发布范围、操作步骤、验证、监控和回滚交给明确消费者。文件位置、版本
格式、分支策略和 tag 政策以项目 adapter 与仓库事实为准，不设通用模板。

## 方法

1. 确认 `release_owner_type`、消费者、环境、发布单位和事实源。
2. 列出范围、依赖、配置/数据变化、部署顺序和权限要求。
3. 定义 preflight、发布后验证、监控窗口、告警 owner 与停止条件。
4. 给出可执行回滚路径、数据兼容边界和不可逆步骤。
5. E2E gate 仅在重要旅程需要该证据时适用；记录实际 verdict 与剩余风险。

项目采用 tag 或发布登记时，可记录：

```yaml
release_owner_type: ""
release_registry_root: ""
release_tag: ""
tag_target_commit: ""
scope: []
deploy: []
verification: []
monitoring: []
rollback: []
evidence: []
open_risks: []
```

- 未采用 tag、SemVer 或发布目录的项目不创建这些字段。
- 已 push 的发布 tag 默认不可移动；修正应遵循项目既有版本政策。
- 规格、测试、产品文档和运行手册只报告项目实际拥有的落地状态，不强制
  生成 SDD / TDD / PRD 套件。
- 交接文档不能代替真实发布授权，也不能把 `blocked` 写成成功。

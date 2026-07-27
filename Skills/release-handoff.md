---
schema: tic_skill.v1
id: release-handoff
status: canonical
phase: release
role: PM / Tech Lead / Release Manager / DS
risk_min: standard
inputs:
  - delivery_evidence
  - release_scope
  - verification_results
outputs:
  - release_handoff_package
  - rollback_plan
  - smoke_checklist
requires:
  - delivery-walkthrough
delegates_to: []
legacy_sources:
  - release-ops-handoff
  - release-train-handoff
---

# Release Handoff（发版交接技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager / DS**
- 触发时机：功能或批次需要交给运维、运营、QA、客服、管理员或生产发布流程
- 输出物：发版交接包、部署/配置说明、运营使用说明、冒烟清单、上线观察、回滚方案、证据归档
- 适用场景：单变更发版、多项目/多服务发版、SQL/脚本发版、运营配置上线、生产反馈闭环

---

## 0. 核心原则

Release Handoff 把“研发完成”转化为“可发布、会使用、能回滚、可观察”。

事实不足时写“待确认”，不得伪造生产域名、窗口、人员、SQL 影响行数或验收结论。

发版计划必须先声明归属。谁拥有发布窗口、版本号/tag、上线顺序和统一回滚，谁就是本次 `release_owner`；父工作区、子项目、独立项目不得同时拥有同一个发版计划，只能一主多引用。

发版按 tag 走时，Release Handoff 必须写清本次使用的 tag、tag 所在仓库、tag 目标 commit、远端状态和部署触发方式。只写版本号、不写 tag 证据，不算完整发版计划。

发布、迁移、回滚、生产变更和 SQL/脚本执行证据必须保留原生命令或 raw 输出。rtk 等输出压缩工具只能作为辅助阅读，不得替代执行结果、影响行数、失败 stderr、回滚证据和审计底稿。

---

## 1. 模式选择

| mode | 使用场景 | 输出位置建议 |
| --- | --- | --- |
| `single` | 单个功能、单个服务、单个跨项目变更 | `<release-registry-root>/<version>/changes/<business-slug>/README.md` |
| `train` | 多服务、多项目、SQL/脚本、全量发版、统一回滚 | `<release-registry-root>/<version>/` |

选择规则：
- 只有一个交付对象且无 SQL/脚本：默认 `single`。
- 超过一个服务/端/脚本/SQL/定时任务/第三方回调：默认 `train`。
- 用户明确要求“发版批次 / release train / 总控包”：使用 `train`。
- `<version>` 必须与 Git Flow release/hotfix tag 完全一致，并符合项目 `version_format`；默认使用 SemVer，例如 `1.2.4`。
- `release_registry_root` 默认是 `docs/releases`；项目可在 `ai-harness/project-adapter.md` 中声明其他登记根。
- 不得在 `release_registry_root` 下新建日期、业务名、需求名或其他非版本号一级目录。
- 版本号是发版容器在该登记根内的唯一主键；业务名、需求名或变更主题是容器内容，应放入 `changes/<business-slug>/`。

业务 slug 规则：

- 使用稳定 kebab-case，例如 `wechat-shop-auto-whitelist`。
- 不带日期，不带 release 版本号，不使用中文目录名。
- 单需求 release train 也必须创建 `changes/<business-slug>/`，不得把业务内容平铺到版本根目录。

---

## 2. 发版归属

发版归属用于决定发版计划和 `release_registry_root` 挂在哪个治理节点下：

| 场景 | 默认归属 |
| --- | --- |
| 独立项目独立部署 | 该项目 |
| 父工作区下多个子项目各自发版 | 各子项目各自拥有发版计划，父工作区只做索引 |
| 多个子项目同一批次上线 | 父工作区或 release train |
| monorepo 内多个 app 共用一次版本/tag | 父工作区 |
| monorepo 内 app 独立版本流 | 对应 app / 子项目 |
| 跨多个独立仓库统一上线 | 指定发版协调仓、治理仓或父工作区 |
| SQL/脚本/全局配置牵涉多个项目 | 默认上升到父工作区或 release train |

必须记录：

- `release_owner_type`：`workspace` / `project` / `subproject` / `external`。
- `release_owner_id`：稳定项目标识或工作区标识。
- `release_registry_root`：发版登记根，默认 `docs/releases`。
- `version_policy`：`shared` / `independent` / `external`。
- 父工作区、子项目和独立仓库之间的引用关系；无法确认时写“待确认”。

---

## 3. Tag 与部署触发

发版计划必须显式写清 tag：

- `release_tag`：本次发布使用的 tag，必须等于 `<version>`。
- `tag_type`：`release` / `hotfix`。
- `tag_repo`：tag 所属仓库或项目。
- `tag_source_branch`：例如 `release/1.2.4` 或 `hotfix/1.2.5`。
- `tag_target_commit`：tag 指向的项目发布提交。
- `remote_tag_status`：未创建 / 本地已创建 / 已 push / 远端已存在。
- `tag_verification_command`：例如 `git rev-parse <tag>^{commit}`。
- `deployment_trigger`：是否由 tag push 触发部署，以及对应流水线、环境和制品。

多项目发版必须提供 tag 映射表：

| 项目 | 仓库 | release/hotfix 分支 | tag | 发布 commit | 远端状态 | 部署制品 |
| --- | --- | --- | --- | --- | --- | --- |

已 push 的发布 tag 默认不可移动。若 tag 打错、落点错误或需要删除/重建远端 tag，必须暂停，记录原因、影响面、拟执行命令和人工确认；不得由 Release Handoff 直接执行。

回滚方案必须写清回滚目标 tag。若数据库、脚本或外部配置不可逆，应写明只能前向修复，并给出验证方式。

---

## 4. 必须收集的事实

- 发版归属：`release_owner_type`、`release_owner_id`、`release_registry_root`、版本策略和项目关系。
- Tag 信息：`release_tag`、tag 类型、仓库、来源分支、目标 commit、远端状态、校验命令。
- 规格与文档落盘：SDD / OpenSpec change、TDD 证据索引、PRD 草稿或正式稿、Walkthrough 的路径和状态。
- 需求来源：PRD、OpenSpec、issue、验收标准。
- 变更范围：diff、服务、前端入口、API 契约、数据库、配置、权限。
- 验证证据：测试、构建、联调、人工验收、截图、日志。
- 发布对象：服务、静态资源、App/H5/小程序、脚本、SQL、定时任务、tag 触发流水线和部署制品。
- 使用对象：运维、运营、QA、客服、管理员、终端用户。
- 风险与回滚：数据风险、配置风险、缓存、第三方、不可逆操作、回滚目标 tag、前向修复条件。
- 输出过滤状态：是否使用过 rtk 等摘要工具；如使用，必须记录 raw 输出或原生命令复核位置。

---

## 5. 输出结构

### mode=single

```markdown
<release-registry-root>/<version>/
└── changes/
    └── <business-slug>/
        └── README.md

## 1. 发版概览
## 2. 发版归属
## 3. Tag 与部署触发
## 4. 本次变更范围
## 5. 发版前置条件
## 6. 部署与配置
## 7. 运营使用手册
## 8. QA / 冒烟清单
## 9. 监控与上线观察
## 10. 回滚与应急
## 11. 上线后反馈闭环
## 12. 待确认事项
```

### mode=train

```text
<release-registry-root>/<version>/
├── README.md
├── changes/
│   └── <business-slug>/
│       └── README.md
├── database/
├── scripts/
├── services/
├── tag-map.md
├── smoke-checklist.md
├── rollback.md
└── evidence.md
```

`changes/<business-slug>/README.md` 建议以 YAML front matter 开头，便于按业务反查版本：

```yaml
---
business: wechat-shop-auto-whitelist
version: 1.2.4
release_tag: 1.2.4
release_owner_type: workspace
release_owner_id: retail-platform
release_registry_root: docs/releases
date: 2026-06-25
---
```

版本根 `README.md` 负责记录本版本总览、发版归属、发布 tag、发布对象、服务顺序、跨业务依赖和回灌状态；`tag-map.md` 负责记录多项目 tag 映射；`database/` 中的 SQL/脚本应保留跨业务全局执行顺序，不应只按业务拆散。

`发版概览` 必须包含：

- `release_owner_type`、`release_owner_id`、`release_registry_root`。
- `<version>`、`release_tag`、tag 类型、tag 仓库、tag 目标 commit 和远端状态。
- 部署触发方式：tag push、手工流水线、制品版本或待确认。
- 本次发布对象和不发布对象。
- SDD / TDD / PRD / Walkthrough 落盘状态。
- 回滚目标 tag 或前向修复说明。

`发版前置条件` 必须包含：

| 产物 | 路径 / 链接 | 状态 | 说明 |
| --- | --- | --- | --- |
| SDD / OpenSpec |  | 已落盘 / 待补 / 不适用 |  |
| TDD / 验证证据 |  | 已落盘 / 待补 / 不适用 |  |
| PRD 草稿 / 正式稿 |  | 已落盘 / 待确认 / 不适用 |  |
| Walkthrough |  | 已落盘 / 待补 / 不适用 |  |

历史兼容：

- 本规则生效前已存在的日期或业务名一级目录可视为遗留归档，但不得新增同类目录。
- 若需要规范化迁移，优先迁移到对应的 `<release-registry-root>/<version>/changes/<business-slug>/` 或版本根发版包；确认无外部链接依赖时可删除旧目录。

---

## 6. 与旧技能关系

本技能是 `release-ops-handoff` 和 `release-train-handoff` 的 canonical 合并版。

- 单变更交付使用 `mode=single`。
- 发版批次、多项目、SQL/脚本使用 `mode=train`。
- 旧入口保留一个兼容周期，wrapper 可透明转向本技能。

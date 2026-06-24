---
schema: tic_skill.v1
id: release-train-handoff
status: alias
canonical: release-handoff
phase: release
role: PM / Tech Lead / Release Manager / DS
risk_min: critical
inputs:
  - delivery_evidence
  - release_train_scope
outputs:
  - release_train_handoff
requires:
  - delivery-walkthrough
delegates_to:
  - release-handoff
---

# Release Train Handoff（发版批次交付包技能）

## 技能用途

- 服务角色：**PM / Tech Lead / Release Manager / DS**
- 触发时机：全量发版、多项目联动发版、单项目标准发版、包含 SQL/脚本/数据库变更的发版、预发/生产发布准备
- 输出物：`docs/releases/<release-id>/` 发版总控包、服务卡、业务联动卡、数据库/脚本 manifest、冒烟、回滚、证据归档
- 适用场景：研发完成后需要把多个项目、服务、SQL、脚本、运营配置、QA 验收和回滚方案统一交付给运维与运营

---

## 0. 核心原则

发版批次是一个独立交付对象，不是某个服务文档的附录。

**主控台管顺序，服务卡管项目细节，业务联动卡管跨项目变化，database/scripts 管可执行数据操作。**

事实不足时写“待确认”，不得把未确认的分支、tag、域名、人员、SQL 影响行数、生产窗口写成事实。

---

## 1. 使用边界

使用本技能：

- 全量发版、多服务发版、多项目联动发版。
- 发版对象超过一个服务、前端、后台、App/H5 包、小程序、Java/Go 服务、定时任务或第三方回调。
- 发版包含 SQL、数据修复、初始化数据、一次性脚本、补偿脚本或定时任务切换。
- 需要统一发版顺序、门禁、冒烟、回滚、上线观察、证据归档。

不要用本技能替代：

- 单个业务功能的运营交付卡：使用 `release-handoff(mode=single)` 或等价项目技能生成 `changes/*.md`。
- 分支创建、merge、tag、push、回灌：使用 `git-flow-operator`。
- OpenSpec 需求提案和实现任务：使用 OpenSpec 流程。

---

## 2. 必须收集的事实

- 需求来源：PRD、OpenSpec、issue、变更说明、验收标准。
- 发版范围：父仓库 diff、子模块指针、各项目 commit/tag、分支、未提交变更。
- Git Flow 状态：当前分支、目标分支、是否需要 `feature/*`、`release/*`、`hotfix/*`、tag、回灌。
- 服务清单：后端服务、管理后台、H5/App、小程序、Java/Go 服务、定时任务、数据脚本、第三方回调。
- SQL/脚本：schema migration、data fix、backfill、verification SQL、pre/post-release scripts、cron/job 切换。
- 验证证据：测试、构建、联调、人工验收、已知缺陷、未测项。
- 使用对象：运维、运营、客服、管理员、QA、研发。

---

## 3. 标准目录

```text
docs/releases/<release-id>/
├── README.md
├── services/
│   └── <project>.md
├── changes/
│   └── <linked-change>.md
├── database/
│   ├── README.md
│   ├── manifest.md
│   ├── precheck.sql
│   ├── migrations/
│   ├── data-fixes/
│   ├── verification.sql
│   └── rollback-notes.md
├── scripts/
│   ├── README.md
│   ├── manifest.md
│   ├── pre-release/
│   ├── release/
│   └── post-release/
├── smoke-checklist.md
├── rollback.md
└── evidence.md
```

裁剪规则：

- 没有 SQL 时保留 `database/manifest.md`，写“本次无数据库变更”。
- 没有脚本时保留 `scripts/manifest.md`，写“本次无一次性脚本或任务切换”。
- 单项目 release 可以只有一个 `services/*.md`，但仍保留 `README.md`、`smoke-checklist.md`、`rollback.md`、`evidence.md`。
- 跨项目业务变化必须进入 `changes/*.md`，不要塞进单个服务卡。

---

## 4. 主控 README.md

必须包含：

1. 发版概览。
2. 本次范围和不在范围内的内容。
3. Git Flow 状态和版本冻结表。
4. 发版顺序，标明可并行和必须串行。
5. 总门禁。
6. 风险和待确认事项。
7. 指向 services、changes、database、scripts、smoke、rollback、evidence 的索引。

---

## 5. 服务卡 services/*.md

每个项目一张服务卡，至少包含：

- 项目概览：类型、职责、版本、制品。
- 本次变更。
- 构建与部署命令。
- 配置项和密钥项。
- 数据库/脚本依赖。
- 项目级冒烟。
- 项目级回滚。
- 已知风险与未测项。

---

## 6. 业务联动卡 changes/*.md

用于描述跨项目业务变化，至少包含：

- 业务目标。
- 涉及项目。
- 端到端数据流。
- 运营使用手册。
- QA 验收。
- 上线观察。
- 回滚与应急。
- 上线后反馈闭环。

---

## 7. SQL 和脚本

SQL 和脚本是一等发版对象，必须有 manifest。

### database/manifest.md 字段

| 字段 | 说明 |
|------|------|
| 顺序 | 执行顺序 |
| 文件 | SQL 文件路径 |
| 类型 | schema / data fix / backfill / verification |
| 所属项目 | 关联项目 |
| 执行时机 | 发版前 / 发版中 / 发版后 / 回滚时 |
| 幂等 | 可重复 / 不可重复 / 需人工判断 |
| 事务 | 单事务 / 分批提交 / 不支持事务 |
| 风险 | 锁表、耗时、影响行数、不可逆 |
| 验证 | 查询 SQL、接口、页面、日志 |

### scripts/manifest.md 字段

| 字段 | 说明 |
|------|------|
| 顺序 | 执行顺序 |
| 脚本 | 脚本路径 |
| 用途 | 执行目的 |
| 参数 | 环境变量或命令参数 |
| 执行环境 | 跳板机、任务机、CI、容器 |
| 幂等 | 可重跑 / 不可重跑 |
| 日志 | 日志位置 |
| 验证 | 执行后验证方式 |

不要默认生成 `rollback.sql`。订单、支付、资金、回调状态、用户行为流水等数据优先写前向修复和人工审批说明。

---

## 8. 质量门槛

- 主 `README.md` 是总控台，不堆所有细节。
- 每个服务一张服务卡，每个跨项目业务变化一张 change 卡。
- 发版顺序必须标明可并行与必须串行。
- 版本冻结必须覆盖父仓库、子模块、独立目录和外部制品。
- Git Flow 状态必须覆盖 feature/release/hotfix 来源、去向、tag 和回灌要求。
- 已知缺陷、未测项、不可逆 SQL、回滚限制必须暴露。
- 运维能照着发版，QA 能照着冒烟，运营能照着配置，研发能照着接收反馈。

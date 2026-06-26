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

---

## 1. 模式选择

| mode | 使用场景 | 输出位置建议 |
| --- | --- | --- |
| `single` | 单个功能、单个服务、单个跨项目变更 | `docs/releases/<version>/changes/<business-slug>/README.md` |
| `train` | 多服务、多项目、SQL/脚本、全量发版、统一回滚 | `docs/releases/<version>/` |

选择规则：
- 只有一个交付对象且无 SQL/脚本：默认 `single`。
- 超过一个服务/端/脚本/SQL/定时任务/第三方回调：默认 `train`。
- 用户明确要求“发版批次 / release train / 总控包”：使用 `train`。
- `<version>` 必须与 Git Flow release/hotfix tag 完全一致，格式为 `数字.数字.三位数字`，例如 `1.0.004`。
- 不得在 `docs/releases/` 下新建日期、业务名、需求名或其他非版本号一级目录。
- 版本号是发版容器唯一主键；业务名、需求名或变更主题是容器内容，应放入 `changes/<business-slug>/`。

业务 slug 规则：

- 使用稳定 kebab-case，例如 `wechat-shop-auto-whitelist`。
- 不带日期，不带 release 版本号，不使用中文目录名。
- 单需求 release train 也必须创建 `changes/<business-slug>/`，不得把业务内容平铺到版本根目录。

---

## 2. 必须收集的事实

- 需求来源：PRD、OpenSpec、issue、验收标准。
- 变更范围：diff、服务、前端入口、API 契约、数据库、配置、权限。
- 验证证据：测试、构建、联调、人工验收、截图、日志。
- 发布对象：服务、静态资源、App/H5/小程序、脚本、SQL、定时任务。
- 使用对象：运维、运营、QA、客服、管理员、终端用户。
- 风险与回滚：数据风险、配置风险、缓存、第三方、不可逆操作。

---

## 3. 输出结构

### mode=single

```markdown
docs/releases/<version>/
└── changes/
    └── <business-slug>/
        └── README.md

## 1. 发版概览
## 2. 本次变更范围
## 3. 发版前置条件
## 4. 部署与配置
## 5. 运营使用手册
## 6. QA / 冒烟清单
## 7. 监控与上线观察
## 8. 回滚与应急
## 9. 上线后反馈闭环
## 10. 待确认事项
```

### mode=train

```text
docs/releases/<version>/
├── README.md
├── changes/
│   └── <business-slug>/
│       └── README.md
├── database/
├── scripts/
├── services/
├── smoke-checklist.md
├── rollback.md
└── evidence.md
```

`changes/<business-slug>/README.md` 建议以 YAML front matter 开头，便于按业务反查版本：

```yaml
---
business: wechat-shop-auto-whitelist
version: 1.0.004
date: 2026-06-25
---
```

版本根 `README.md` 负责记录本版本总览、发布对象、服务顺序、跨业务依赖和回灌状态；`database/` 中的 SQL/脚本应保留跨业务全局执行顺序，不应只按业务拆散。

历史兼容：

- 本规则生效前已存在的日期或业务名一级目录可视为遗留归档，但不得新增同类目录。
- 若需要规范化迁移，优先迁移到对应的 `docs/releases/<version>/changes/<business-slug>/` 或版本根发版包；确认无外部链接依赖时可删除旧目录。

---

## 4. 与旧技能关系

本技能是 `release-ops-handoff` 和 `release-train-handoff` 的 canonical 合并版。

- 单变更交付使用 `mode=single`。
- 发版批次、多项目、SQL/脚本使用 `mode=train`。
- 旧入口保留一个兼容周期，wrapper 可透明转向本技能。

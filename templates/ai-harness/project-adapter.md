# 项目适配说明模板

bootstrap 默认会基于目标项目自动生成 `ai-harness/project-adapter.md`。本模板仅作为兜底参考，用于脚本无法探测或团队手工维护时补充。

## 项目画像

- 产品 / 服务：
- 主要用户：
- 技术栈：
- 主要入口：
- 部署目标：

## 项目关系与产物归属

请按真实情况维护。父工作区、多子项目、独立项目或多仓联动时，AI 以这里的归属为准；未确认项写“待确认”。

```yaml
artifact_ownership:
  owner_type: project # workspace | project | subproject | external
  owner_id: "待确认"
  parent_workspace: ""
  child_projects: []
  related_repositories: []
artifact_roots:
  sdd_root: "openspec/changes" # 无 OpenSpec 时可用 docs/sdd
  tdd_evidence_root: "docs/test-evidence"
  prd_root: "docs/PRD"
  prd_draft_root: "docs/PRD/drafts"
  walkthrough_root: "docs/walkthroughs"
release_ownership:
  owner_type: project # workspace | project | subproject | external
  owner_id: "待确认"
  release_registry_root: "docs/releases"
  version_policy: independent # shared | independent | external
  version_format: semver # semver | three-digit-patch | calendar | custom
  branch_strategy: project-defined # trunk | gitflow | project-defined
  feature_base: "待确认"
  release_base: "待确认"
  hotfix_base: "待确认"
  tag_policy: "preserve-existing" # preserve-existing | no-v-prefix | v-prefix | custom
  deployment_trigger: "tag-push" # tag-push | manual-pipeline | external | 待确认
```

## 常用命令

```bash
# 安装依赖

# lint

# 类型检查

# 测试

# 构建
```

## 可选工具

| 工具 | 默认启用 | 用途 | 限制 |
| --- | --- | --- | --- |
| rtk | false | 只读、高噪音、幂等命令的输出压缩 | Git Flow、迁移、生产、破坏性操作和失败调试使用原生命令或 raw 输出 |

项目如需启用 rtk，应在本文件或项目规则中显式改为 `true`，并确认团队环境已关闭 telemetry。

```yaml
rtk_enabled: false
rtk_native_only:
  - git push/merge/cherry-pick/rebase/tag/reset
  - release/hotfix/tag/back-merge
  - migration/schema/data-repair
  - production deploy/rollback/destructive-ops
```

## 模块地图

| 区域 | 路径 | 说明 |
| --- | --- | --- |
| 前端 |  |  |
| 后端 |  |  |
| 测试 |  |  |
| 文档 |  |  |

## Agent 会话协议

如项目需要多 agent 独立会话或异步执行，使用 `ai-harness/agent-session-protocol.md` 和 `.tic/agent-runs/` 记录运行态。目录名面向用户可读；`run_id`、`agent_id`、`session_id` 只用于机器追踪。

## 风险边界

列出需要额外谨慎、人工确认或回滚方案的区域：

- 认证 / 权限：
- 支付 / 资金：
- 数据迁移：
- 生产配置：
- 外部集成：

## 本地决策

记录未来 AI 会话必须延续的项目级决策：

-

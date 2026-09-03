# TIC 0.5.3 产品基线与 PRD 工作流修复

## 问题

0.5.2 的 outcome-driven 模型减少了普通任务的流程负担，但试运行暴露了两个
非对称缺口：

1. 大型新产品缺少已确认产品基线时，Agent 仍可能连续建设 API、Schema、领域
   模型和管理页面，最后再从实现反推 PRD；
2. UI 规则主要约束实现后的真实界面验证，没有约束实现前的角色、主旅程、信息
   架构和关键状态。

结果是每个技术纵切都可能局部正确，整体产品却发生范围膨胀。开发后 PRD Sync
若直接接受代码事实，还会把偏移写回正式产品事实源，形成破坏性闭环。

## 决策

### 普通任务保持直接

稳定产品内的 Bug、局部 UI 修复、重构和技术验证继续采用 inline 计划、针对性
验证和任务上下文交付。0.5.3 不恢复默认 Orchestrator 或全任务阶段流水线。

### 产品基线保护持久实现

新产品、业务域或重大用户旅程同时缺少已确认产品基线，且实现将通过 API、Schema、
菜单、状态或领域模型冻结产品行为时：

- `planning_depth=living`；
- `fact_persistence=prd`；
- 产品方向使用 `review_level=user-decision`；
- 确认前只允许调查、原型、PRD 草稿和可逆技术探针；
- 产品包含 UI 时，先明确角色、主旅程、信息架构和关键状态。

这不是按文件数或技术关键词升级，而是由“尚未确认的产品决定即将被持久实现”这一
事实触发。

### 三项 PRD 能力分离

| 能力 | 责任 | 禁止承担 |
| --- | --- | --- |
| `prd-author` | 创建或重写产品基线，保持 DRAFT 直到 owner 确认 | 技术架构和开发后反推 |
| `prd-review-checklist` | 审查基线、UI、验收、证据和破坏性模式 | 批准实现、迁移或发布 |
| `post-dev-prd-sync` | 同步已有批准证据的交付行为 | 创建初始基线或掩盖规格漂移 |

`Prompts/ai-prd-generator.rules.md` 从固定章节和 FE/BE 自动拆分模板改为按需求形状
选择章节的写作参考。PRD 只描述业务数据需求，OpenSpec/SDD 或契约承载精确技术结构。

## 破坏性链路

0.5.3 明确阻断以下反馈环：

```text
技术风险
→ 新模块/页面/状态
→ 局部测试通过
→ 开发后 PRD 接受现状
→ 产品范围被实现反向扩大
```

无批准证据的实现差异进入 `spec_drift`，正式 PRD 保持不变，由 owner 选择修代码
或改变产品决定。

## 兼容

- 0.5.2 的五个独立维度、按事实选择 Capability 和消费者驱动 artifact 保持不变；
- `prd-review-checklist` 的 canonical 文件名不变，仅新增可发现 wrapper；
- `post-dev-prd-sync` 保持原 ID，收紧同步前提；
- 兼容 alias 的 0.6.0 生命周期不在本版本处理。

## 验收

- greenfield 未确认、已确认基线、稳定产品 UI Bug、开发后规格漂移四个场景可执行；
- `tic-prd-author`、`tic-prd-review`、`tic-post-dev-prd-sync` 均可由全局安装器渲染；
- PRD 生成参考覆盖目标、主旅程、UI 状态、验收和状态证据，且不强制固定模板；
- canonical Skill 保持 180 行以内且没有固定角色流水线；
- 0.5.2 的安装、adapter/memory 保留、E2E 和 Capability 边界回归继续通过。

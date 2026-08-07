# TIC 0.5.1 原生 Workflow 语义收口

## 决策

TIC 只管理边界，不接管 Agent 执行。移除三种综合执行模式，改用五个互相
独立的判断：

1. `planning_depth`
2. `execution_authority`
3. `verification_scope`
4. `review_level`
5. `fact_persistence`

任务契约使用 outcome、boundaries、done、verification、authority。普通任务
直接执行；只有产品结果无法从事实判断或具体动作需要额外授权时暂停。

## 外部能力

Codex 原生调查、计划、调试、验证、Review 和协作能力默认可直接使用。
Superpowers 是按需方法库，不能作为 umbrella workflow。OpenSpec 是长期规格
事实源，只在存在跨任务、跨项目、多人或审计消费者时使用。

## 验证与 Review

验证从完成标准开始，在修改后就近运行，并在交付前产生新鲜最终证据。
Review 根据对象放置：架构和公共契约在实现前，代码在实现与验证后，生产和
发布动作在执行前。普通交付做 diff 自审；公共契约、跨项目和高后果变更使用
独立 Review。

## 验收

- Workflow Core 不再声明三种综合模式。
- 场景能够表达“大型但自主”和“小型但需确认”。
- 项目模板明确外部 Skills 非总入口、OpenSpec 非默认入口。
- 旧 CP 与任务档位只允许出现在迁移说明中。
- 安装保持 adapter、memory 和项目自定义内容。

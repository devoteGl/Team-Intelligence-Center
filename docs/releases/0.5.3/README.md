# Team-Intelligence-Center 0.5.3

0.5.3 修复大型新产品在缺少产品和 UI 基线时直接进入持久实现的问题，同时保持
普通任务的轻量、直接执行体验。

## 发布信息

- 状态：本地候选，尚未发布
- release owner：Team-Intelligence-Center
- 候选 tag：`0.5.3`
- tag policy：无 `v` 前缀、annotated tag、preserve-existing
- 发布分支：`master`
- 集成分支：`develop`
- 权威远端：`origin`
- 部署触发：tag push 后进入 stable 更新通道，不触发业务生产部署

## 主要变化

- 新增 `prd-author` 及 `tic-prd-author` wrapper；
- 新增 `tic-prd-review` wrapper，保留 PRD Review Checklist 的窄责任；
- 收紧 `post-dev-prd-sync`，无批准证据的差异进入规格漂移；
- PRD 生成提示词改为产品基线和按需章节，不再自动拆 FE/BE；
- 新增产品/UI 基线门和四类行为场景；
- 保持普通 Bug、局部 UI 修复和重构直接执行。

## 交付归属

- SDD：`docs/sdd/tic-0.5.3-product-baseline-prd-workflow.md`
- 测试证据：`docs/test-evidence/tic-0.5.3/README.md`
- Walkthrough：`docs/walkthroughs/tic-0.5.3-product-baseline-prd-workflow.md`
- Git 与远端证据：`docs/releases/0.5.3/evidence.md`

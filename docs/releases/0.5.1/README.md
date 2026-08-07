# Team-Intelligence-Center 0.5.1

0.5.1 收口 GPT-5.6 / Codex 原生工作方式：TIC 管理授权与事实边界，Agent
直接执行，外部 Skills 按需提供方法。

## 发布信息

- 状态：已发布至 `origin` 并完成 `develop` 回灌
- release owner：Team-Intelligence-Center
- release 分支：`release/0.5.1`
- release tag：`0.5.1`
- tag policy：无 `v` 前缀、annotated tag
- 发布分支：`master`
- 集成分支：`develop`
- 部署触发：tag push 后进入 stable 更新通道，不触发业务生产部署

## 主要变化

- 五个独立决策维度取代综合任务模式。
- 增加 verification 与 authority 任务契约字段。
- 验证贯穿执行，Review 按对象与影响触发。
- Superpowers 非默认总控，OpenSpec 非默认任务入口。
- 全局 Loader 和项目入口缩短为规则发现与关键边界。

## 交付归属

- SDD：`docs/sdd/tic-0.5.1-native-workflow-convergence.md`
- 测试证据：`docs/test-evidence/tic-0.5.1/README.md`
- Walkthrough：`docs/walkthroughs/tic-0.5.1-native-workflow-convergence.md`
- Git 与远端证据：`docs/releases/0.5.1/evidence.md`

tag 落点、回灌提交和远端状态在发布后证据中记录。

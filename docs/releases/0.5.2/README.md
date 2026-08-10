# Team-Intelligence-Center 0.5.2

0.5.2 把 Skill 从“旧流程的文档节点”收敛为精确触发、独立可用的方法能力。

## 发布信息

- 状态：发布候选；tag、push 与回灌状态在发布后证据中回填
- release owner：Team-Intelligence-Center
- release 分支：`release/0.5.2`
- release tag：`0.5.2`
- tag policy：无 `v` 前缀、annotated tag、preserve-existing
- 发布分支：`master`
- 集成分支：`develop`
- 权威远端：`origin`
- 部署触发：tag push 后进入 stable 更新通道，不触发业务生产部署

## 主要变化

- 重写 canonical Skills，移除固定角色、阶段、报告和跨能力推荐链。
- 收紧所有全局 wrapper 的自动发现描述。
- 新增 capability non-trigger 场景和 Skill 体积预算。
- Git 复用明确授权，且只刷新权威远端。
- artifact 与固定目录彻底解耦，按真实消费者生成。
- 兼容 alias 计划在 0.6.0 移除。

## 交付归属

- SDD：`docs/sdd/tic-0.5.2-skill-capability-convergence.md`
- 测试证据：`docs/test-evidence/tic-0.5.2/README.md`
- Walkthrough：`docs/walkthroughs/tic-0.5.2-skill-capability-convergence.md`
- Git 与远端证据：`docs/releases/0.5.2/evidence.md`

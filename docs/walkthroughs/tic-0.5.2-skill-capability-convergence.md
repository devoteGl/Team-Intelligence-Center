# TIC 0.5.2 交付走查

## 为什么改

0.5.1 的 Workflow Core 已经轻量，但 Skill 正文和 wrapper 描述仍可能自动把
普通任务拖入调查、契约、仲裁、文档与二次确认。

## 改了什么

- 14 个 canonical Skills 收敛为一个能力、一个触发边界、一个最小方法。
- wrapper 的描述从“何时在流程前后调用”改为“什么事实精确成立”。
- 共享文件、API、开发完成和行为变化均增加 non-trigger 场景。
- Git 保留保护但复用明确授权；发布和文档只服务真实消费者。
- 兼容入口只做名称跳转，不恢复旧流程。

## 如何 review

1. 查看 `Workflow/scenarios.json` 中新增正反场景。
2. 检查每个 Skill 的 `activation.when/not_when` 是否互相闭合。
3. 检查全局 wrapper `description` 是否与 canonical 激活事实一致。
4. 运行 `bash tools/validate-pack.sh`。

## 预期体验

普通任务直接做；需要某种专门方法时才加载对应 Skill。Skill 提供约束和方法，
不接管整个任务，也不自动要求其他 Skill、OpenSpec 或 Superpowers。

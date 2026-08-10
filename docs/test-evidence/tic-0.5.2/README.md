# TIC 0.5.2 Test Evidence

维护命令：

```bash
bash tools/validate-pack.sh
```

新增验收覆盖：

- canonical Skills 不含旧 tier、CP、角色/阶段链，并保持 180 行预算；
- wrapper descriptions 不编码 before/after 顺序或关键词式宽触发；
- code investigation、shared domain、internal API、walkthrough、PRD persistence
  的正反激活场景；
- 当前任务明确 Git 授权后不重复确认；
- manifest 中 alias、subflow、checklist 和 rule template 生命周期一致。

最终执行结果与 Git 证据记录在 `docs/releases/0.5.2/evidence.md`。

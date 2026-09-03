# TIC 0.5.3 Test Evidence

## 失败基线

在 0.5.2 基线上先扩展 `tools/validate-pack.sh`。新增检查稳定发现：

- 缺少 `prd-author`；
- PRD Review 没有可发现 wrapper；
- greenfield 和规格漂移场景缺失；
- 产品/UI 基线未保护持久实现；
- PRD 生成提示词仍强制固定结构和 FE/BE 拆分；
- 0.5.3 版本、发布和走查资产缺失。

## 通过条件

维护命令：

```bash
bash -n tools/*.sh
jq empty manifest.json Workflow/scenarios.json
bash tools/validate-pack.sh
git diff --check
```

执行结果：

- `bash -n tools/*.sh`：通过；
- `jq empty manifest.json Workflow/scenarios.json`：通过；
- 三个 PRD wrapper `quick_validate.py`：通过；
- `bash tools/validate-pack.sh`：零失败，一个 `pwsh` 缺失 warning；
- `git diff --check`：通过。

完整结果同步记录在 `docs/releases/0.5.3/evidence.md`。PowerShell 运行时 fixture
只在环境存在 `pwsh` 时执行；缺失时保持明确 warning。

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

同一验证器还覆盖：

- `tic-gitflow-v1` 分支名和中文 scoped commit 正反例；
- 权威远端新鲜度、长期分支保护、tag 回灌和 submodule 顺序；
- 已知旧 TIC Skill 的哈希识别、备份删除和自定义 Skill 保留；
- Shell/PowerShell 安装实现对齐；无 `pwsh` 时仅保留运行时 warning。

合并 Git 与 PRD 两批变更后的首次验证发现新增 Wrapper 仍使用旧 resolver 顺序，
并因 Bash `set -euo pipefail` 在匹配缺失时提前退出。修复后所有 Wrapper 使用
`local_config → lock → fallback`，验证器能够把缺失匹配计为失败并继续运行到
最终汇总；复验明确输出 `Validation passed`。

完整结果同步记录在 `docs/releases/0.5.3/evidence.md`。PowerShell 运行时 fixture
只在环境存在 `pwsh` 时执行；缺失时保持明确 warning。

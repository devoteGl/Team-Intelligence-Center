# 0.5.3 验证证据

## 当前状态

- 状态：发布候选已准备，尚未推送
- release 分支：`release/0.5.3`
- 集成分支：`develop@e0d6e08`
- 基线：`origin/develop@8213a65`
- release owner：Team-Intelligence-Center
- 候选 tag：`0.5.3`
- 发布远端：`gitee`、`github`
- 明确排除：`origin`

## 行为验证

- RED：0.5.2 在新增检查下出现 16 项失败，覆盖缺失 Skill/wrapper、greenfield
  门禁、UI 基线、规格漂移和版本资产。
- GREEN：`bash tools/validate-pack.sh` 零失败；本机没有 `pwsh`，PowerShell 运行时
  fixture 保持一个明确、非阻断 warning。
- 结构：`jq empty manifest.json Workflow/scenarios.json` 通过。
- Shell：`bash -n tools/*.sh` 通过。
- Skill：`tic-prd-author`、`tic-prd-review`、`tic-post-dev-prd-sync` 三个 wrapper
  均通过 `quick_validate.py`。
- 规模：24 个 Skill 文件、15 个 canonical capability、17 个全局 wrapper；
  `prd-author`、PRD Review 和开发后同步正文均低于 180 行。
- 安装：验证器在临时 Codex Home 渲染 0.5.3 Loader 和三个 PRD wrapper，未修改
  真实 Codex Home。
- Git：分支/提交校验器、权威远端、长期分支保护、回灌、submodule 顺序及已知
  旧 Skill 安全迁移回归通过。
- 自审：`git diff --check` 通过；24 个变更相关 Markdown 文件的相对链接均可达；
  完整 diff Review 修复一处产品基线门重复措辞，并移除 PRD Author 对 Review 的
  隐形自动串联。
- 集成回归：首次合并态验证因两个新增 Wrapper 未采用 `local_config → lock →
  fallback` 顺序而在 resolver 循环提前退出；已统一 Wrapper 并使缺失匹配显式
  进入失败判断。复验输出到最终 `Validation passed` 且退出码为 0。

## Git 与发布边界

- Git feature commit：`9249d54`（`feat(git-flow): 统一仓库协作与校验策略`）。
- PRD feature commits：`98e5e28`、`639f156`。
- Git feature 合入 develop：`bfaeebd`。
- PRD feature 合入 develop：`c2139ce`。
- SemVer 分支兼容修复：`813c28c`，合入 develop：`e0d6e08`。
- feature push：未执行。
- release branch：已创建，准备提交。
- `master` 合入、annotated tag、`develop` 回灌：未执行。
- 当前记录不得被解释为已发布或已进入 stable 更新通道。

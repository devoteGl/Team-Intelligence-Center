# Git 协作标准

本文件是 TIC 的 Git 命名、基线与发布合并事实源。项目 adapter 可以声明经过
确认的例外；未声明例外时使用 `tic-gitflow-v1`。

## 分支模型

- `master`：可发布稳定分支，只接收 release、hotfix 或明确批准的紧急变更。
- `develop`：日常集成分支，普通任务分支的默认基线与合入目标。
- `feature/<slug>`：新功能，基于 `develop`。
- `fix/<slug>`：非生产紧急缺陷，基于 `develop`。
- `docs/<slug>`、`style/<slug>`、`refactor/<slug>`、`perf/<slug>`、
  `test/<slug>`、`chore/<slug>`、`ci/<slug>`、`revert/<slug>`：对应类型任务，
  基于 `develop`。
- `release/<version>`：发布准备，基于 `develop`，完成后合入 `master` 并回灌
  `develop`。
- `hotfix/<version>`：生产热修，基于 `master`，完成后合入 `master` 并回灌
  `develop`。

`slug` 使用 2–40 个小写 ASCII 字母、数字和连字符，可用工单号开头；使用具体
业务含义，不使用中文、空格、纯日期或 `project`、`misc`、`update`、`changes`
等泛化名称。版本分支使用无 `v` 的三段数字，补丁位补足三位，例如
`release/4.4.405`。

`master`、`develop` 是受保护长期分支。普通任务不得直接在其上提交或推送。
若当前任务改动已位于长期分支，在基线与远端一致且改动范围唯一时，先创建
对应任务分支再暂存；基线落后、分叉或改动混杂时暂停并请求处理决定。

## Commit Message

首行固定格式：

```text
<type>(<scope>): <中文祈使句>
```

- `type` 仅允许 `feat`、`fix`、`docs`、`style`、`refactor`、`perf`、`test`、
  `chore`、`ci`、`revert`。
- `scope` 必填，使用小写 ASCII kebab-case，指向真实领域或模块，例如
  `settlement`、`payment-proof`、`admin-web`、`workflow`；不使用 `project`、
  `misc`、`general`、`update`、`changes` 等兜底词。
- subject 使用简洁中文祈使句，不超过 50 个字符，结尾不加句号。
- 有正文时，首行后空一行；正文每行不超过 72 个字符。
- 破坏性变更在 footer 使用 `BREAKING CHANGE: <说明>`。

示例：

```text
feat(settlement): 增加结算批次审批
fix(payment-proof): 修复待审核凭证可重复编辑
chore(workflow): 统一 Git 提交与分支策略
```

每个 commit 只表达一个可回滚意图。暂存使用显式路径，提交前核对
`git diff --cached`；本地配置、密钥、运行态文件和无关用户改动不进入提交。

## 写操作顺序

1. 解析权威 remote、当前分支、目标分支、基线、upstream 和待写 ref。
2. 分支、合并或 tag 前执行
   `git fetch <authoritative-remote> --prune --tags`。
3. 核对基线与远端同步、同名分支占用、工作树归属和恢复方式。
4. 分支名通过 `tools/validate-branch-name.*`，commit message 通过
   `tools/validate-commit-msg.*`。
5. 暂存显式路径并复核 staged diff；完成适当验证后提交。
6. 只推送当前任务分支并建立明确 upstream；普通任务不直接推送
   `master` 或 `develop`。
7. 每个写操作后用 `status`、`show-ref`、`merge-base` 和远端 refs 验证。

默认禁止 force push。确需改写未共享任务分支时，只能在用户明确授权具体 ref
后使用 `--force-with-lease`；不得 force push 长期分支或已发布 tag。

## 合并、发布与 submodule

- 合并、删除分支、tag 和发布必须有当前任务的明确授权。
- feature/fix 等任务分支合入 `develop`；release/hotfix 合入 `master` 后回灌
  `develop`。项目明确采用其他策略时，以 adapter 为准并记录例外。
- release tag 创建在 `master` 的已验证发布 commit 上，使用 annotated tag、
  无 `v` 前缀和项目声明的版本格式。已存在或已推送 tag 不得移动或覆盖。
- submodule 先在子仓库完成分支、验证、提交与推送，再在父仓任务分支更新指针；
  父仓提交必须记录所有子仓 commit，并执行父仓兼容性验证。

历史分支和 commit 不因本标准自动重写。历史修复、长期分支初始化或远端策略
调整属于单独的受保护动作。

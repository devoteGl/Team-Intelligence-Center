# TIC 0.5.3 Git 工作流标准化

## 问题

0.5.2 允许项目自行声明分支、版本和 tag 策略，但默认值分散在规则、adapter、
Shell/PowerShell 安装器和建议脚本中。长期分支直接提交、泛化 scope、远端基线
未刷新和旧 TIC Skill 镜像残留都可能造成不可追溯或破坏性 Git 操作。

## 决策

新增 `tic-gitflow-v1` 作为无项目例外时的默认策略：

- `master` 只承载可发布稳定状态，`develop` 承载日常集成；
- 普通任务使用类型分支，release/hotfix 按项目声明回灌；
- commit 使用必填具体 scope 的中文 Conventional Commit；
- 分支和提交信息由 Shell/PowerShell 校验器在写操作前检查；
- force push 默认禁止，已发布 tag 不移动；
- submodule 先提交推送子仓，再更新父仓指针并验证兼容性。

## 安装与兼容

项目 `.tic-rules.local` 明确声明可访问的 `rules_source=local_config` 时，优先于
分支控制的 lock，避免业务分支切换回旧规则。bootstrap 和全局安装器只移除哈希
匹配的已知旧 TIC Skill 副本，先备份；同名自定义 Skill 和未知文件保持原样。

Project Adapter 新增 Git profile、权威 remote、受保护分支、commit、版本、tag
和回灌默认值。已有 adapter 继续逐字节保留，只有显式维护时更新。

## 验收

- 合法 feature/release 分支通过，泛化或非 ASCII slug 被拒绝；
- 合法中文 scoped commit 通过，缺 scope、泛化 scope 和英文 subject 被拒绝；
- Git 建议脚本保持只读并只刷新权威远端；
- Shell/PowerShell 安装路径对已知旧 Skill 先备份再移除，对自定义 Skill 保留；
- bootstrap、全局安装、adapter 保留和 0.5.2 Workflow 回归继续通过。

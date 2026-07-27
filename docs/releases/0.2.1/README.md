# 0.2.1 发布记录

- 状态：发布版；本发布提交作为 `0.2.1` tag 目标，远端与回灌结果见发布后证据
- 发布日期：2026-07-27
- 基线版本：`0.2.0`
- 基线提交：`8f28cc8`
- 发布分支：`hotfix/0.2.1`
- 发布 tag：`0.2.1`
- 权威远端：`origin`
- 发布归属：Team-Intelligence-Center
- release owner type：`project`
- release registry root：`docs/releases`
- tag 类型：`hotfix`
- tag 来源：`hotfix/0.2.1` 合入 `master` 后的发布提交
- 发布后校验命令：`git rev-parse 0.2.1^{commit}`
- 部署触发：tag push 后供 stable 更新通道选择，不触发业务生产部署

## 版本目标

修复 0.2.0 普通更新可能覆盖项目 `project-adapter.md` 的问题，把 adapter 从一次性 AI 摘要明确为项目维护的事实与治理配置。

## 版本变更

- 普通安装、刷新和升级默认保留现有 adapter。
- 新增显式、有备份的 adapter 完整重生成参数。
- 新增 `project-adapter-maintainer` canonical Skill 和 Codex wrapper。
- 首次生成 adapter 时识别 `.gitmodules` 子项目与 workspace 归属。
- 新增 Shell 行为回归测试和 PowerShell 结构一致性检查。

## 发布前检查

- [x] `0.2.0` 已有独立归档记录和 tag
- [x] hotfix 从 `origin/master` 的 `0.2.0` 基线创建
- [x] `VERSION` 与 `manifest.json` 更新为 `0.2.1`
- [x] 规则包最终校验通过
- [ ] PowerShell 运行时验证（环境无 PowerShell 时记录为未测）
- [x] 用户确认 commit
- [x] 用户确认合并、tag、push 和回灌
- [x] 发布前确认本地与远端不存在同名 `0.2.1` tag
- [ ] tag 目标 commit 与远端状态由发布后原生 Git 证据确认

## 冒烟与回滚

- 发布前冒烟：`bash tools/validate-pack.sh`、`bash -n tools/*.sh`、`jq empty manifest.json`、`git diff --check`。
- 发布后冒烟：stable tag 可见，业务项目 `.tic-rules.lock` 更新为 `0.2.1`，已有 adapter 校验和不变。
- 回滚目标：tag `0.2.0`。
- 回滚方式：业务项目执行 `tools/update.sh --ref 0.2.0 --project <project>`；已恢复的 adapter 不随规则版本回滚。

规格见 [../../sdd/tic-0.2.1-project-adapter-preservation.md](../../sdd/tic-0.2.1-project-adapter-preservation.md)，验证证据见 [../../test-evidence/tic-0.2.1/README.md](../../test-evidence/tic-0.2.1/README.md)，发布后 Git 证据见 [evidence.md](evidence.md)。

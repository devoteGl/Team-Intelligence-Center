# 0.2.2 发布记录

- 状态：发布版；本发布提交作为 `0.2.2` tag 目标，远端与回灌结果见发布后证据
- 发布日期：2026-07-27
- 基线版本：`0.2.1`
- 基线提交：`62e4ab19e8b59700c9b9cf62fe5d61e8ab626d5a`
- 发布分支：`hotfix/0.2.2`
- 发布 tag：`0.2.2`
- 权威远端：`origin`
- 发布归属：Team-Intelligence-Center
- release owner type：`project`
- release registry root：`docs/releases`
- version policy：`independent`
- tag 类型：`hotfix`
- tag 来源：`hotfix/0.2.2` 合入 `master` 后的发布提交
- 部署触发：tag push 后供 stable 更新通道选择，不触发业务生产部署
- 回滚目标：`0.2.1`，需使用该版本已记录的更新规避参数

## 版本目标

修复 0.2.1 在 macOS Bash 3.2 下默认一键更新因空数组展开退出的问题。

## 版本变更

- 可选 Codex home 改用标量路径保存。
- 默认路径与显式路径统一由 `refresh_codex_global` 处理。
- 新增隔离回归，覆盖默认 preview、默认 apply 和显式路径透传。

## 发版前置条件

| 产物 | 路径 | 状态 | 说明 |
| --- | --- | --- | --- |
| SDD | `docs/sdd/tic-0.2.2-bash32-update.md` | 已落盘 | 行为与验收标准 |
| TDD 证据 | `docs/test-evidence/tic-0.2.2/README.md` | 已落盘 | 红绿回归与最终校验 |
| PRD | 不适用 | 已记录 | 开发工具兼容修复，无业务 PRD |
| Walkthrough | `docs/walkthroughs/tic-0.2.2-bash32-update.md` | 已落盘 | Review 与使用说明 |
| Release Handoff | `changes/bash32-update/README.md` | 已落盘 | 单变更交接 |

## 发布门禁

- [x] 已从新鲜的 `origin/master` 创建 `hotfix/0.2.2`
- [x] 创建前已确认本地与远端不存在同名分支和 tag
- [x] 用户确认 commit、合并、tag、push、回灌和业务工作区更新
- [x] 最终代码审查通过（14 个文件，0 个问题，`APPROVE`）
- [x] 规则包和 Bash 3.2 冒烟通过
- [x] tag 目标与远端状态由原生 Git 命令确认
- [x] develop 回灌与发版目录落点确认
- [x] 父子项目和全局 Loader 更新为 `0.2.2`

规格见
[../../sdd/tic-0.2.2-bash32-update.md](../../sdd/tic-0.2.2-bash32-update.md)，
测试证据见
[../../test-evidence/tic-0.2.2/README.md](../../test-evidence/tic-0.2.2/README.md)，
发布后证据见 [evidence.md](evidence.md)。

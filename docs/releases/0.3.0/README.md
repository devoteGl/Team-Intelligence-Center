# 0.3.0 发布记录

- 状态：本地验证通过；等待 Git Flow 完整链路确认
- 目标日期：2026-07-31
- 基线版本：`0.2.2`
- 基线 tag commit：`0a55134555d25eab38220961db9f251375ef606c`
- 开发基线：`develop` / `b14badb43ba5bfa950be3f024e37105b9fc00aea`
- 功能分支：`feature/e2e-verification-standardization`
- 候选发布分支：`release/0.3.0`
- 候选 tag：`0.3.0`
- 权威远端：`origin`
- 发布归属：Team-Intelligence-Center
- release owner type：`project`
- release registry root：`docs/releases`
- version policy：`independent`
- tag policy：无 `v` 前缀
- 部署触发：tag push 后供 stable 更新通道选择，不触发业务生产部署

## 版本目标

把 TIC 的端到端验证从分散的 UI / 浏览器建议升级为按风险触发、工具中立、可审计的 Verification Gate，同时保持 consulting / micro 轻量和现有 Project Adapter 的保护性升级语义。

## 版本变更

- 新增 canonical `Skills/e2e-verification.md`。
- 新增 Codex 全局 `tic-e2e-verification` wrapper。
- `tic-workflow-orchestrator` 在 Verification phase 条件路由 E2E。
- `project-adapter.md` 新增 `verification.e2e` schema。
- Shell / PowerShell bootstrap 首次生成器保持 schema 对齐。
- Shell / PowerShell marker refresh 保持字节级幂等，不累积 `AGENTS.md`
  文件末尾空白行。
- Release Handoff 和 Delivery Walkthrough 接收 E2E requirement、journey coverage、verdict 与证据。
- 规则包验证新增 E2E 路由、adapter、wrapper、安全边界和安装回归。

## 发版前置条件

| 产物 | 路径 | 状态 | 说明 |
| --- | --- | --- | --- |
| SDD | `docs/sdd/tic-0.3.0-e2e-verification-standardization.md` | 已落盘 | 行为、边界和验收标准 |
| TDD / 验证证据 | `docs/test-evidence/tic-0.3.0/README.md` | 已落盘 | 规则包与安装 fixture |
| E2E gate | `docs/test-evidence/tic-0.3.0/README.md` | `passed` | 规则包 targeted journey |
| PRD | 不适用 | 已记录 | 开发工作流规则能力，无业务产品行为 |
| Walkthrough | `docs/walkthroughs/tic-0.3.0-e2e-verification-standardization.md` | 已落盘 | Review 与验证说明 |
| Release Handoff | `docs/releases/0.3.0/changes/e2e-verification-standardization/README.md` | 已落盘 | tag、部署、冒烟、回滚与反馈闭环 |

## 候选发布门禁

- [x] 功能分支从新鲜 `develop` 创建
- [x] 本地与远端无同名功能分支
- [x] 规格、canonical Skill、wrapper、adapter schema 和文档已落盘
- [x] adapter 普通刷新逐字节保留回归通过
- [x] marker 重复 refresh 幂等与旧尾部空行自愈回归通过
- [x] Shell / manifest / wrapper / 临时安装验证通过
- [x] 真实业务工作区父项目与 7 个已接入子项目接入烟测通过
- [x] 本地逻辑 review 无阻塞问题
- [x] PowerShell 运行时验证作为长期验证项，不阻塞本次发布
- [ ] 用户确认 commit、release 分支、合并、tag、push 和回灌
- [ ] tag 目标、远端状态和 stable 更新结果回填

规格见
[../../sdd/tic-0.3.0-e2e-verification-standardization.md](../../sdd/tic-0.3.0-e2e-verification-standardization.md)，
测试证据见
[../../test-evidence/tic-0.3.0/README.md](../../test-evidence/tic-0.3.0/README.md)。

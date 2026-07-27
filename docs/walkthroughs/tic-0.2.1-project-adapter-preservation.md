# TIC 0.2.1 Project Adapter 保护性升级 - Delivery Walkthrough

## 1. 交付摘要

- **一句话结论**：团队继续使用原来的一条更新命令，已有 `project-adapter.md` 不再被浅层自动探测结果覆盖。
- **当前状态**：独立代码审查已 APPROVE，用户已授权 commit、merge、tag、push 与 develop 回灌。
- **关联来源**：用户反馈、`docs/sdd/tic-0.2.1-project-adapter-preservation.md`、`hotfix/0.2.1`。
- **适用读者**：规则维护者、项目 owner、Reviewer、使用 TIC 的研发。

## 2. 本次完成了什么

| 项 | 说明 | 证据 |
| --- | --- | --- |
| 默认保留 adapter | 普通安装、refresh、force 和 update 不修改现有 adapter | `tools/bootstrap-project.*`、`tools/install.*`、回归测试 |
| 显式重生成 | 只有独立参数才会备份后重生成 | `--regenerate-adapter` / `-RegenerateAdapter` |
| 工作区识别 | 首次生成时读取 `.gitmodules`，写入子项目并标记 workspace | Shell/PowerShell 生成器与临时 fixture |
| 保护性维护 Skill | 支持 create、enrich、audit、migrate、repair | `Skills/project-adapter-maintainer.md` |
| 团队更新说明 | README、USAGE、模板和自动化文档统一说明默认保留行为 | 文档 diff |

## 3. 使用路径

普通使用者仍执行：

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh --project /path/to/project
```

规则入口会刷新，现有 `ai-harness/project-adapter.md` 保持不变。需要补全、审计、迁移或恢复时调用 `project-adapter-maintainer`。

只有明确放弃当前 adapter 时才执行：

```bash
bash /path/to/Team-Intelligence-Center/tools/install.sh \
  --regenerate-adapter /path/to/project
```

Windows 对应参数为 `-RegenerateAdapter`。完整重生成前会写入 `.tic-backups/<timestamp>/`。

## 4. 技术实现走查

更新链保持原结构：

```text
update --project
  -> install --refresh
    -> bootstrap --force
      -> 刷新生成入口
      -> preserve existing project-adapter.md
```

adapter 重生成使用独立状态：

```text
install --regenerate-adapter
  -> bootstrap --regenerate-adapter
    -> backup existing adapter
    -> generate detected profile
```

关键设计决策：

| 决策 | 原因 | 取舍 |
| --- | --- | --- |
| `--force` 与 adapter 重生成解耦 | 兼容用户现有更新命令，同时消除隐式覆盖 | 增加一个显式高级参数 |
| 现有内容不做自动 schema 迁移 | 项目事实和自定义章节优先 | schema 补全交给 Skill 做证据驱动合并 |
| `.gitmodules` 进入首次画像 | 根目录可能没有业务技术栈文件 | 自动结果仍是脚手架，需项目维护 |

## 5. 变更文件与影响面

| 文件 / 模块 | 类型 | 影响 |
| --- | --- | --- |
| `tools/bootstrap-project.sh/.ps1` | 修改 | adapter 分流、备份、workspace 探测 |
| `tools/install.sh/.ps1` | 修改 | 暴露显式重生成参数 |
| `tools/validate-pack.sh` | 修改 | 新增 adapter 生命周期回归 |
| `Skills/project-adapter-maintainer.md` | 新增 | 统一保护性维护流程 |
| `templates/codex-global/skills/tic-project-adapter-maintainer/` | 新增 | Codex 全局轻量入口 |
| `VERSION`、`manifest.json`、`CHANGELOG.md` | 修改 | 0.2.1 版本与能力登记 |
| README、USAGE、templates、docs | 修改 / 新增 | 用户说明、规格、证据与候选发布记录 |

## 6. 验证证据

### 已执行

| 验证项 | 命令 / 方法 | 结果 |
| --- | --- | --- |
| Shell 语法 | `bash -n tools/*.sh` | 通过 |
| manifest | `jq empty manifest.json` | 通过 |
| diff 格式 | `git diff --check` | 通过 |
| 规则包 | `bash tools/validate-pack.sh` | `Validation passed.` |
| 默认保留 | 临时 adapter 执行 bootstrap `--force` 前后比较校验和 | 通过 |
| 显式重生成 | 检查新文件、备份 sentinel、workspace 和子项目 | 通过 |
| 用户更新链 | `update --no-pull --no-global --project <fixture>` | adapter 不变，lock 为 0.2.1 |
| Codex wrapper | `skill-creator/scripts/quick_validate.py` | 通过 |
| 独立代码审查 | code-reviewer 审查全部 diff 与未跟踪新增文件 | 22 个文件，0 个问题，APPROVE |

### 未执行

| 验证项 | 原因 | 剩余风险 | 建议补救 |
| --- | --- | --- | --- |
| PowerShell 运行时解析与行为测试 | 当前环境没有 `pwsh` | Windows 特有语法或编码差异 | 发布前在 Windows 或带 `pwsh` 的 CI 运行同等 fixture |
| 真实远端更新 | 尚未实际创建并 push tag | stable 通道在 tag 发布前不会选中 0.2.1 | Git Flow 发布后验证远端 stable 更新 |

## 7. Review 指引

- 优先看 `tools/bootstrap-project.sh` 和 `tools/bootstrap-project.ps1` 中模板刷新与 adapter 重生成是否使用了不同开关。
- 核对 `update -> install --refresh -> bootstrap --force` 是否始终落到 preserve 分支。
- 核对 `.gitmodules` 路径转 YAML 的 Shell / PowerShell 对齐。
- 核对 `project-adapter-maintainer` 是否坚持非占位事实优先和冲突待确认。
- 文档重点检查是否仍有“用 `--force` 刷新 adapter”的旧指导。

## 8. 风险与待确认

| 级别 | 内容 | 处理建议 |
| --- | --- | --- |
| 重要 | PowerShell 尚未运行时验证 | 发布前补 Windows / pwsh 验证，或明确接受结构对照证据 |
| 已处理 | 受影响业务工作区的 adapter 已从最近完整备份恢复，当前文件与备份 SHA-256 一致 | 保留为项目未提交改动，由项目 owner 后续审阅提交 |
| 已解除 | commit、merge、tag、push 和 develop 回灌已获用户明确授权 | 按 Git Flow 顺序执行并保留原生 Git 证据 |

## 9. 后续动作

- 业务工作区 owner 审阅已恢复的 adapter，并决定是否单独提交。
- 按 `git-flow-operator` 完成发布，并在 release handoff 中记录 tag 落点、远端状态和 develop 回灌证据。

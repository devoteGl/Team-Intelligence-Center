# TIC 0.2.0 本地验证证据

- 验证日期：2026-07-27
- 结论：Shell、规则包、Git 更新通道、项目安装刷新和 Codex 全局 Loader 验证通过。
- 未测项：当前环境未安装 PowerShell，`tools/*.ps1` 未做运行时解析和行为测试；PowerShell 实现已与 Shell 路径做结构对照。

## 静态验证

通过项：

- `git diff --check`
- `bash -n tools/update.sh tools/install.sh tools/bootstrap-project.sh tools/git-advice.sh tools/install-global.sh`
- `jq empty manifest.json`
- `bash tools/validate-pack.sh`

`validate-pack.sh` 最终结果为全部检查通过。

## 临时 Git 集成验证

测试使用独立临时源仓库、bare 远端和消费端 clone，构造 `0.1.0` 与 `0.2.0` tag，没有修改真实远端。

通过项：

- `--channel current` 对跟踪分支执行 fast-forward，并到达远端新提交。
- 默认 `stable` 通道只从指定远端公布的 tag 中选择最高 SemVer `0.2.0`，不会误选消费端本地未发布的 `9.9.9` tag。
- `--ref <branch>` 优先解析指定远端的跟踪分支并到达远端最新提交。
- `--ref 0.1.0` 切换到归档提交 `d8fe814ad633bd06d6ead7815ad8f7d6d3db5324`，且 `VERSION` 为 `0.1.0`。
- 规则源存在未提交文件时，更新脚本拒绝切换版本。
- 以 `-` 开头的 ref/remote 和未知选项会被拒绝。
- 项目适配器声明 `release_base: main` 时，Git 建议输出 `expected_base_branch: main`，并标明来源为项目适配器。

## 安装与刷新验证

通过项：

- 向空白临时业务项目执行首次安装。
- 对同一项目执行 `--refresh`。
- 两次执行后 `.tic-rules.lock` 均记录 `rules_version=0.2.0`。
- 向独立临时 Codex home 安装全局 Loader 和 `tic-*` 包装器。
- 全局 `AGENTS.md` 包含 TIC Loader 标记，工作流包装器存在。

## 发布边界

本次验证没有创建真实分支、commit、tag、push 或远端 Release。稳定更新通道只有在 `0.2.0` tag 经用户确认并发布后，才会成为其他使用者的默认升级入口。

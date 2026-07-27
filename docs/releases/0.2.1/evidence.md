# 0.2.1 发布后 Git 证据

本文件记录 `0.2.1` 的真实 tag、权威远端、回灌和业务工作区更新结果。
`0.2.1` tag 已发布且不移动；发布后 stable 冒烟发现的一键更新缺陷单独记录，
后续只能通过新版本修复。

## Git 证据

- hotfix 提交：`5f5d03d710a52179ddb6ed6677b7fbc27da3f49b`
- `master` 发布提交：`62e4ab19e8b59700c9b9cf62fe5d61e8ab626d5a`
- `0.2.1` tag 落点：`62e4ab19e8b59700c9b9cf62fe5d61e8ab626d5a`
- `origin/master`：`62e4ab19e8b59700c9b9cf62fe5d61e8ab626d5a`
- `origin/develop` 回灌落点：`86f1cd643a540a843b807897e77a967593beb1b4`
- `origin` annotated tag 对象：`bd3b7a7830de64cd08b29c90275678df7beec7ad`
- `origin` tag 解引用：`62e4ab19e8b59700c9b9cf62fe5d61e8ab626d5a`
- develop 回灌提交：`86f1cd643a540a843b807897e77a967593beb1b4`
- `git merge-base --is-ancestor 0.2.1^{commit} develop`：退出码 `0`

## 工作区更新证据

- 规则子模块：切换到 `0.2.1` tag 对应提交 `62e4ab1`
- 父项目：`live-project-workspace` 的 lock 已更新为 `0.2.1`
- 子项目：8 个子项目的 lock 均已更新为 `0.2.1`
- 既有 adapter：7 个文件更新前后校验和一致
- 首次接入：`java_new_client`、`dczd_uniapp_h5` 创建 adapter
- Codex 全局 Loader：已更新为 `0.2.1`，并安装
  `tic-project-adapter-maintainer` wrapper
- 业务仓库边界：只更新本地规则文件，没有替业务仓库提交或推送

## 发布后冒烟与已知问题

- `bash tools/update.sh --preview --no-pull --no-project`：失败
- `bash tools/update.sh --no-pull --no-project`：失败
- 运行时：macOS GNU Bash `3.2.57`
- 失败位置：`tools/update.sh` 展开空的 `CODEX_HOME_ARG` 数组时报
  `unbound variable`
- 影响：未显式传入 `--codex-home` 且启用默认全局 Loader 刷新时，
  preview 和普通应用路径都会退出
- 已验证临时规避：显式传入 `--codex-home <path>` 的 preview 通过
- 不受影响：本次使用 `install.sh --refresh --rules-dir ...` 完成的父子项目更新；
  adapter 保留逻辑本身已通过回归和真实工作区校验
- 处理边界：不移动已推送的 `0.2.1` tag；建议创建 `0.2.2` hotfix

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.2.1^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.2.1
git merge-base --is-ancestor 0.2.1^{commit} develop
```

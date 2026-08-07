# 0.3.0 发布证据

本文件记录 `0.3.0` 的 tag、权威远端、develop 回灌、stable 更新和
真实业务工作区升级结果。

## Git 证据

- 功能提交：`c3ddd6237d5899852246d134f544726b87d66100`
- release 准备提交：`97911831b82e48a0060144dbab84b3c48d9d3f0c`
- `master` 发布提交：`44a5360a6e1307eeeee177b452703e4b25474d5e`
- `0.3.0` tag 落点：`44a5360a6e1307eeeee177b452703e4b25474d5e`
- 本地 annotated tag 对象：`abbd8017517ec5bfc106361c3940ce154f899d33`
- develop 回灌提交：`a68955e4690aaf74437d2449f8e2999d08b59bb4`
- `git merge-base --is-ancestor 0.3.0^{commit} develop`：退出码 `0`
- `origin/master` 仍为 `0a55134555d25eab38220961db9f251375ef606c`
- `origin/develop` 仍为 `b14badb43ba5bfa950be3f024e37105b9fc00aea`
- `origin` 不存在 `0.3.0` tag；本次按用户要求不 push
- 活跃 `release/*`：远端无；本地发布分支在证据提交后清理

## 本地 tag 更新冒烟

- 从本地 annotated tag `0.3.0` 创建隔离 detached worktree。
- 使用 `update.sh --no-pull` 在隔离项目和隔离 Codex home 执行完整更新。
- 规则包校验通过，项目 lock 为 `rules_version=0.3.0`。
- 隔离 Codex 全局 Loader 记录规则版本 `0.3.0`，并安装
  `tic-e2e-verification` wrapper。
- 临时 worktree、项目与 Codex home 已精确清理。
- 远端 stable 通道选择未验证；原因是用户明确要求本次不 push。

## 业务工作区证据

- 0.3.0 开发态已在 `live-project-workspace` 父项目和 7 个已接入子项目
  执行本地 refresh smoke。
- 父子项目 lock 解析、Project Adapter 保留、子模块隔离和受管文件格式
  均通过。
- 发布 tag 本体另以隔离 worktree 完成安装冒烟。
- 真实业务工作区的 tag 固定与长期验证将在 0.4.0 试运行阶段继续执行。

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.3.0^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.3.0
git merge-base --is-ancestor 0.3.0^{commit} develop
```

# 0.2.2 发布后证据

本文件记录 `0.2.2` 的 tag、权威远端、develop 回灌、stable 冒烟和
真实业务工作区升级结果。

## Git 证据

- hotfix 提交：`619ac54136487690ec251d13348d8fcb7861b489`
- `master` 发布提交：`0a55134555d25eab38220961db9f251375ef606c`
- `0.2.2` tag 落点：`0a55134555d25eab38220961db9f251375ef606c`
- `origin/master`：`0a55134555d25eab38220961db9f251375ef606c`
- `origin/develop` 回灌落点：`7946224a322676f0634f9770f622399974ff952a`
- `origin` annotated tag 对象：`31f8b2c0b7833eb5446ed1e0b22db7bf8796c1b0`
- `origin` tag 解引用：`0a55134555d25eab38220961db9f251375ef606c`
- develop 回灌提交：`7946224a322676f0634f9770f622399974ff952a`
- `git merge-base --is-ancestor 0.2.2^{commit} develop`：退出码 `0`
- 活跃 `release/*`：无，不需要额外回灌

## Stable 更新冒烟

- 从 0.2.1 首次跨版本：显式传入 `--codex-home` 后，stable 通道选择
  `0.2.2` 并完成规则源、全局 Loader 和父项目刷新。
- 0.2.2 默认 preview：不传 `--codex-home`，成功输出全局 Loader 与
  项目刷新计划。
- 0.2.2 默认 apply：不传 `--codex-home`，完成规则包校验和全局 Loader
  刷新。
- 运行时：macOS GNU Bash `3.2.57`。
- 结论：0.2.2 后续恢复普通一条命令；0.2.1 用户第一次升级需使用下方
  一次性参数。

```bash
bash /path/to/Team-Intelligence-Center/tools/update.sh \
  --project /path/to/project \
  --codex-home /path/to/.codex
```

## 业务工作区证据

- 规则子模块：`0a55134555d25eab38220961db9f251375ef606c`
- 父项目：`live-project-workspace` lock 为 `0.2.2`
- 子项目：8 个子项目 lock 均为 `0.2.2`
- Project Adapter：父项目与 8 个子项目更新前后 SHA-256 全部一致
- Codex 全局 Loader：规则版本为 `0.2.2`
- 业务仓库边界：只更新本地规则文件和子模块工作树，没有替业务仓库提交或推送

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.2.2^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.2.2
git merge-base --is-ancestor 0.2.2^{commit} develop
```

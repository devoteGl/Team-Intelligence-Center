# 0.3.0 发布证据

本文件记录 `0.3.0` 的 tag、权威远端、develop 回灌、stable 更新和
真实业务工作区升级结果。

## Git 证据

- 功能提交：待回填
- `master` 发布提交：待回填
- `0.3.0` tag 落点：待回填
- `origin/master`：待回填
- `origin/develop` 回灌落点：待回填
- `origin` annotated tag 对象：待回填
- `origin` tag 解引用：待回填
- develop 回灌提交：待回填
- 活跃 `release/*`：待发布后复核

## Stable 更新冒烟

- stable 通道选择：待 tag push 后验证
- 默认 preview：待 tag push 后验证
- 默认 apply：待 tag push 后验证
- 结论：待回填

## 业务工作区证据

- 规则子模块：待更新并回填
- 父项目 lock：待更新并回填
- 子项目 lock：待更新并回填
- Project Adapter：待复核升级前后校验和
- Codex 全局 Loader：待更新并回填

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.3.0^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.3.0
git merge-base --is-ancestor 0.3.0^{commit} develop
```

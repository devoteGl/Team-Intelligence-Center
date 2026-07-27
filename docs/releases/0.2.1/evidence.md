# 0.2.1 发布后 Git 证据

本文件在候选发布提交中先建立证据槽位。真实 tag、远端和回灌结果必须在 Git Flow 执行完成后，以原生 Git 命令回填到项目集成分支。

## 待回填

- hotfix 提交：
- `master` 发布提交：
- `0.2.1` tag 落点：
- `origin/master`：
- `origin/develop`：
- `origin` 远端 tag：
- develop 回灌提交：
- `git merge-base --is-ancestor <release-commit> develop`：
- stable 更新冒烟：
- 父子项目 lock 更新：
- 既有 adapter 校验和保护：

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.2.1^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.2.1
git merge-base --is-ancestor 0.2.1^{commit} develop
```

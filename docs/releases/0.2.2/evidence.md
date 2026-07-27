# 0.2.2 发布后证据

本文件在候选提交中建立证据槽位。tag、权威远端、develop 回灌和业务工作区
结果必须在发布动作完成后，用原生 Git 命令回填到集成分支。

## 待回填

- hotfix 提交：
- `master` 发布提交：
- `0.2.2` tag 落点：
- `origin/master`：
- `origin/develop` 回灌落点：
- `origin` annotated tag 对象：
- `origin` tag 解引用：
- develop 回灌提交：
- `git merge-base --is-ancestor 0.2.2^{commit} develop`：
- stable preview：
- stable apply：
- 父子项目 lock：
- 既有 adapter 校验和：
- Codex 全局 Loader：

## 验证命令

```bash
git rev-parse master
git rev-parse develop
git rev-parse 0.2.2^{commit}
git ls-remote origin refs/heads/master refs/heads/develop refs/tags/0.2.2
git merge-base --is-ancestor 0.2.2^{commit} develop
```

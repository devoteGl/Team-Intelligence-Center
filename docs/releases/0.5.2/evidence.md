# 0.5.2 验证证据

## 发布策略

- release owner：Team-Intelligence-Center
- release tag：`0.5.2`
- tag 类型：annotated release tag
- 权威远端：`origin`
- tag policy：preserve-existing
- 部署触发：tag push 后进入 stable 更新通道

## Git 与回灌证据

- `master` 发布提交：`2c470bea357d8d76d2fd0f41cca9e8da677d62a9`
- `0.5.2` tag 落点：`2c470bea357d8d76d2fd0f41cca9e8da677d62a9`
- `origin/master`：`2c470bea357d8d76d2fd0f41cca9e8da677d62a9`
- `develop` 回灌提交：`515e6b4ab79360de3cd9175e3b45ed7dd9b9ef94`
- `origin/develop`：包含上述回灌提交及发布后证据提交
- `origin` annotated tag 对象：`20f632abb8a820f573d62fc1df2410883fc79c97`
- `origin` tag 解引用：`2c470bea357d8d76d2fd0f41cca9e8da677d62a9`
- `git merge-base --is-ancestor 0.5.2^{commit} develop`：退出码 `0`
- 远端 `release/*`：无；`release/0.5.2` 未推送
- push：`master`、`develop` 和 `0.5.2` 通过一次 atomic push 完成

## 功能验证

- RED：0.5.1 在新增检查下出现 4 类失败：旧阶段语言、Skill 体积超限、
  wrapper 过度触发、缺少 non-trigger/授权复用场景。
- GREEN：`bash tools/validate-pack.sh` 零失败。
- Review：完整 diff 自审，重点检查激活边界、自动级联、Git 授权和 artifact
  ownership。
- 安装：临时 Codex Home 渲染以及本机全局 Loader/wrapper 同步。
- PowerShell：本机无 `pwsh`，运行时 fixture 未执行；静态检查通过并保留为
  非阻断 warning。

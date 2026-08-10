# 0.5.1 验证证据

## 发布策略

- release owner：Team-Intelligence-Center
- release tag：`0.5.1`
- tag 类型：release
- tag 来源：`release/0.5.1` 合入 `master` 后的发布提交
- 权威远端：`origin`
- 部署触发：tag push 后进入 stable 更新通道

## Git 与回灌证据

- `master` 发布提交：`34f2b5c76407bacd9f40c4eadae30f0f39b40efd`
- `0.5.1` tag 落点：`34f2b5c76407bacd9f40c4eadae30f0f39b40efd`
- `origin/master`：`34f2b5c76407bacd9f40c4eadae30f0f39b40efd`
- `develop` 回灌提交：`1474711eca1fd461413e63bbf53fd5df6398b7e3`
- `origin` annotated tag 对象：`eb0f84304dcbcdb78ffdae5bdb64906e61206a40`
- `origin` tag 解引用：`34f2b5c76407bacd9f40c4eadae30f0f39b40efd`
- `git merge-base --is-ancestor 0.5.1^{commit} develop`：退出码 `0`
- 远端 `release/*`：无；`release/0.5.1` 未推送
- push：`master`、`develop` 和 `0.5.1` 通过一次 atomic push 完成

## 功能验证

- RED：旧 0.5.0 模型被新增的五维模型断言以 6 项失败拒绝。
- GREEN：`bash tools/validate-pack.sh` 必须零失败。
- 场景：本地 Bug、大型本地重构、共享 API、关键旅程、生产迁移、Memory
  候选和 release push。
- 安装：Shell fixture 验证入口幂等，并保持 adapter 与 shared memory。
- PowerShell：仅在环境存在 `pwsh` 时运行等价 fixture。

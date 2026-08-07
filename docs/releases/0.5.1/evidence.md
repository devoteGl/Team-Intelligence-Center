# 0.5.1 验证证据

## 发布策略

- release owner：Team-Intelligence-Center
- release tag：`0.5.1`
- tag 类型：release
- tag 来源：`release/0.5.1` 合入 `master` 后的发布提交
- 权威远端：`origin`
- 部署触发：tag push 后进入 stable 更新通道
- tag 落点、远端状态与 `develop` 回灌结果：发布后回填

## 功能验证

- RED：旧 0.5.0 模型被新增的五维模型断言以 6 项失败拒绝。
- GREEN：`bash tools/validate-pack.sh` 必须零失败。
- 场景：本地 Bug、大型本地重构、共享 API、关键旅程、生产迁移、Memory
  候选和 release push。
- 安装：Shell fixture 验证入口幂等，并保持 adapter 与 shared memory。
- PowerShell：仅在环境存在 `pwsh` 时运行等价 fixture。

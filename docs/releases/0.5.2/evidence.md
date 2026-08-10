# 0.5.2 验证证据

## 发布策略

- release owner：Team-Intelligence-Center
- release tag：`0.5.2`
- tag 类型：annotated release tag
- 权威远端：`origin`
- tag policy：preserve-existing
- 部署触发：tag push 后进入 stable 更新通道

## Git 与回灌证据

发布完成后回填 master 落点、tag object、远端 refs、develop 回灌和祖先关系。

## 功能验证

- RED：0.5.1 在新增检查下出现 4 类失败：旧阶段语言、Skill 体积超限、
  wrapper 过度触发、缺少 non-trigger/授权复用场景。
- GREEN：`bash tools/validate-pack.sh` 零失败。
- Review：完整 diff 自审，重点检查激活边界、自动级联、Git 授权和 artifact
  ownership。
- 安装：临时 Codex Home 渲染以及本机全局 Loader/wrapper 同步。

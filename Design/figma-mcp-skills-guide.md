# Figma MCP + Skills 通用使用说明

本文面向组织内所有项目的产品、设计和研发协作者，说明如何使用 Figma MCP 与 Figma skills 完成设计读取、设计稿生成、设计转代码、设计系统规则沉淀、Code Connect 映射等工作。

本文不绑定某一个业务项目。文中的目录、端类型和组件路径均为通用示例；落到具体项目时，以该项目 README、目录结构和本地规则配置为准。

## 1. 一句话理解

Figma MCP 负责让 AI 读取或写入 Figma 文件；Figma skills 负责规定 AI 应该按什么流程、边界和质量标准使用这些能力。

简单说：

- **Figma MCP** 是工具通道。
- **Figma skills** 是操作规程。
- **Figma 链接或选中节点** 是输入。
- **PRD、接口契约、代码、Figma 画布、设计系统规则、Code Connect 映射** 是输出。

产品/设计不需要关心 MCP 的调用细节，只需要把 **目标、链接、范围、验收标准和禁止事项** 说清楚。AI 会根据任务选择合适的 Figma skill，并按 skill 的流程调用 MCP 工具。

## 2. 已安装 Skills

组织 AI 协作环境建议安装以下 Figma skills：

| Skill                              | 适用场景                                   | 产品/设计怎么理解                  |
| ---------------------------------- | ------------------------------------------ | ---------------------------------- |
| `figma`                            | 读取 Figma 设计上下文、截图、变量、资源    | 通用入口，用于理解设计稿           |
| `figma-implement-design`           | Figma 设计稿转生产代码                     | “请按这个 Figma 页面/组件实现前端” |
| `figma-use`                        | 写入 Figma 文件、创建/修改节点、变量、组件 | “请直接帮我改 Figma 文件”          |
| `figma-generate-design`            | 从文字、代码或页面生成 Figma 设计稿        | “请在 Figma 里生成一个页面/界面”   |
| `figma-create-new-file`            | 新建 Figma / FigJam 文件                   | “请新建一个 Figma 文件”            |
| `figma-code-connect-components`    | 建立 Figma 组件与代码组件映射              | “让设计组件和代码组件长期绑定”     |
| `figma-create-design-system-rules` | 从 Figma 生成 AI 设计系统规则              | “让 AI 以后按我们的设计系统写代码” |
| `figma-generate-library`           | 生成或更新 Figma 设计系统组件库            | “帮我搭一套设计系统组件库”         |

### 2.1 安装命令

先安装 `find-skills`，再通过 `find-skills` 安装 Figma 官方 skills。组织内部如果还有补充 skills，也通过 `find-skills` 继续安装。

#### 2.1.1 配置 Figma MCP

```toml
[features]
rmcp_client = true

[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
```

```bash
export FIGMA_OAUTH_TOKEN="<your-figma-oauth-token>"
```

#### 2.1.2 安装 find-skills

```bash
npx skills add https://github.com/vercel-labs/skills --skill find-skills -g -y
```

安装完成后重启 Codex 或对应 AI 工具。

#### 2.1.3 使用 find-skills 安装 Figma 官方 skills

重启后，在 Codex 对话中输入：

```text
请使用 find-skills 安装 Figma 官方 MCP skills，来源使用 Figma 官方仓库：
https://github.com/figma/mcp-server-guide

需要安装：
- figma-use
- figma-code-connect-components
- figma-create-design-system-rules
- figma-create-new-file
- figma-implement-design
- figma-generate-design
- figma-generate-library
```

#### 2.1.4 使用 find-skills 安装组织内部补充 skills

如果组织内部有项目专用、行业专用或流程补充 skills，在 Codex 对话中输入：

```text
请使用 find-skills 查找并安装组织内部的 <skill 名称或关键词> skills。
```

#### 2.1.5 重启并验证

安装后重启 Codex 或对应 AI 工具，然后发送：

```text
请读取这个 Figma Frame，返回页面结构摘要，并说明是否已成功获取 design context 和截图：
<Figma 链接>
```

常见问题：

- 识别不到 skill：重启 AI 工具。
- token 无效：检查 `FIGMA_OAUTH_TOKEN`。
- 能读不能写：检查 Figma 文件编辑权限。
- 读错页面：复制具体 Frame / Component 的链接。

## 3. 角色分工

| 角色 | 主要负责                                      | 需要提供给 AI 的信息                              |
| ---- | --------------------------------------------- | ------------------------------------------------- |
| 产品 | 需求目标、业务流程、字段规则、验收标准        | PRD、用户路径、状态枚举、异常规则、接口消费方     |
| 设计 | Figma 页面、组件、变量、设计系统约束          | 精确 Frame/Component 链接、视觉参考、组件复用要求 |
| 研发 | 目标端、代码边界、技术约束、验证命令          | 项目路径、页面路由、已有组件、接口契约            |
| AI   | 读取/写入 Figma、生成文档、实现代码、验证差异 | 根据任务选择 skill 和 MCP 工具                    |

建议产品/设计在需求开始时就给 AI 两类输入：

- **业务输入**：这个页面解决什么问题，用户要完成什么动作。
- **设计输入**：要读取或修改哪个 Figma 节点，哪些地方必须严格一致。

## 4. 使用前准备

### 4.1 Figma 侧准备

产品/设计需要提供以下任一种输入：

- Figma 文件链接。
- Figma Frame / Section / Component 链接。
- Figma 节点 ID。
- 在 Figma Desktop 中打开文件并选中节点。

推荐提供 **精确到 Frame 或组件的链接**，不要只给文件首页。

链接示例：

```text
https://www.figma.com/design/<fileKey>/<fileName>?node-id=123-456
```

复制链接时建议在 Figma 中选中目标 Frame / Component 后使用 “Copy link to selection”。如果是一个完整页面，请选中页面主 Frame；如果是组件实现或 Code Connect，请选中组件或组件集。

### 4.2 权限准备

- AI 使用的 Figma 账号需要能访问目标文件。
- 如果要写入 Figma，目标文件需要可编辑权限。
- 如果要复用设计系统组件，目标文件需要能访问对应 Library。
- 如果要做 Code Connect，Figma 组件需要已发布到团队 Library，且账号计划需要支持 Code Connect。

### 4.3 项目侧准备

研发或 AI 应先读取目标项目中的：

- 项目 README。
- AI 规则使用说明。
- 技术栈、组件库、路由、状态管理和接口规范。
- 目标端的启动、检查和构建命令。

如果项目接入了组织规则仓库，应优先使用组织统一规则；如果项目存在本地补充规则，以项目更近层级的规则为准。

### 4.4 提问必填信息

建议每次使用 Figma MCP 时至少说明：

| 信息       | 示例                                                             |
| ---------- | ---------------------------------------------------------------- |
| 任务目标   | “根据这个 Frame 生成后台审核页 PRD”                              |
| Figma 输入 | “链接：...”                                                      |
| 目标端     | 后台 Web / H5 / 小程序 / App / 服务端 / 只改 Figma               |
| 输出位置   | 项目约定的 PRD、接口契约、代码或设计文档目录                     |
| 验收标准   | “布局对齐 Figma，状态包含待审核/通过/驳回”                       |
| 禁止事项   | “不要覆盖已有组件，不要新增依赖，不要直接保存 Code Connect 映射” |

## 5. 场景选择

### 5.1 设计稿转代码

使用 `figma-implement-design`。

适合：

- 把 Figma 页面实现到后台 Web。
- 把 Figma 页面实现到 H5、小程序或 App。
- 把 Figma 组件转成项目组件。

产品/设计需要给：

- Figma 精确链接。
- 目标端：例如后台 Web、H5、小程序、App。
- 期望交互和状态说明。
- 是否允许研发按现有组件库做轻微适配。

推荐提法：

```text
请使用 figma-implement-design，把这个 Figma Frame 实现到目标项目：
<Figma 链接>

目标端：<后台 Web / H5 / 小程序 / App>
目标路径：<项目路径或页面路由>

要求：
- 优先复用项目已有组件和样式规范。
- 保持与 Figma 视觉一致。
- 如果 Figma 和现有组件规范冲突，先说明取舍。
- 实现后给出验证方式。
```

AI 应做：

1. 读取 Figma design context。
2. 获取截图作为视觉基准。
3. 下载或引用 Figma 资源。
4. 映射到项目现有组件、路由、状态管理和样式规范。
5. 实现代码。
6. 运行验证。

验收重点：

- 视觉布局是否一致。
- 字体、间距、颜色、圆角是否接近。
- 空状态、加载态、错误态是否覆盖。
- 交互是否与产品预期一致。
- 代码是否复用现有组件，而不是硬画一套。

### 5.2 在 Figma 中生成页面

使用 `figma-generate-design` + `figma-use`。

适合：

- 产品描述一个新页面，让 AI 在 Figma 中生成初稿。
- 根据已有代码或页面截图反向生成 Figma 页面。
- 根据 PRD 生成后台、H5、小程序或 App 页面草图。

产品/设计需要给：

- 页面目标。
- 用户角色。
- 页面包含哪些区块。
- 业务字段。
- 设计系统或参考页面。
- 目标 Figma 文件链接。

推荐提法：

```text
请使用 figma-generate-design，在这个 Figma 文件里生成一个 <业务页面名称>：
<Figma 文件链接>

页面需要包含：
- 筛选区：<字段列表>
- 列表/表格/卡片区：<字段列表>
- 操作：<操作列表>
- 状态：<状态枚举>

请优先复用文件中已有设计系统组件。
```

AI 应做：

1. 先检查 Figma 文件中已有页面、组件、变量和样式。
2. 搜索并复用设计系统组件。
3. 先创建页面外框，再分区块生成。
4. 每生成一个关键部分就返回节点 ID。
5. 用截图检查布局。

验收重点：

- 是否复用设计系统组件。
- 页面结构是否符合业务流程。
- 文案和字段是否准确。
- 是否有可继续编辑的图层结构。

### 5.3 直接修改 Figma 文件

使用 `figma-use`。

适合：

- 批量改组件命名。
- 新增变量、颜色、间距 token。
- 调整 Auto Layout。
- 修改组件 variants。
- 清理重复节点。

产品/设计需要给：

- 目标文件。
- 目标页面或节点。
- 具体改动。
- 是否允许批量修改。

推荐提法：

```text
请使用 figma-use，帮我在当前 Figma 文件中把 <组件名称> 补齐 <状态列表>。

要求：
- 不要改已有主状态的视觉。
- 新增 variants 后截图给我确认。
- 返回新增或修改的节点 ID。
```

注意：

- 写入 Figma 是真实修改文件。
- 大批量修改前应先让 AI 检查现有结构。
- 高风险修改应先在副本文件中试跑。

### 5.4 新建 Figma 文件

使用 `figma-create-new-file`。

适合：

- 新建一个需求评审文件。
- 新建一个设计系统草稿文件。
- 新建一个 FigJam 流程图文件。

推荐提法：

```text
请使用 figma-create-new-file，新建一个 Figma design 文件：
名称：<项目名> - <需求名> 设计

创建后请在文件中生成：
- 页面 1：流程说明
- 页面 2：核心页面草图
- 页面 3：状态枚举和错误提示
```

### 5.5 Figma 组件绑定代码组件

使用 `figma-code-connect-components`。

适合：

- 设计系统组件已经稳定。
- 代码组件也已经存在。
- 希望设计和代码组件建立长期映射。

产品/设计需要给：

- Figma 组件链接。
- 代码组件路径。
- 组件属性映射关系。

推荐提法：

```text
请使用 figma-code-connect-components，把 Figma <组件名> 组件映射到项目中的 <代码组件名> 组件。

Figma：
<组件链接>

代码组件：
<项目相对路径，例如 src/components/...>

请先给出建议映射，不要直接保存，等我确认。
```

验收重点：

- Figma variants 是否能对应代码 props。
- 文案、图标、状态是否能映射。
- 是否存在不能映射的设计属性。

### 5.6 从 Figma 生成 AI 设计系统规则

使用 `figma-create-design-system-rules`。

适合：

- 希望 AI 以后写前端时遵守设计系统。
- 需要把 Figma tokens、组件、版式约定沉淀成规则。
- 项目准备进入长期 AI 辅助开发。

推荐提法：

```text
请使用 figma-create-design-system-rules，从这个 Figma 设计系统文件生成适合组织项目复用的 AI 前端规则：
<Figma 文件链接>

输出请包含：
- 颜色 token 使用规则
- 字体和字号规则
- 间距和栅格规则
- 常用组件复用规则
- 禁止事项
```

如果规则属于组织通用设计系统，应回写到组织规则仓库；如果只适用于单个项目，应放在该项目的本地规则或设计文档目录。

### 5.7 生成或更新 Figma 组件库

使用 `figma-generate-library`。

适合：

- 从现有产品页面抽象组件库。
- 生成 Button、Input、Table、Modal 等组件 variants。
- 补齐设计系统基础组件。

建议由设计负责人主导，不建议普通需求开发中随意使用。

推荐提法：

```text
请使用 figma-generate-library，在目标 Figma 文件中生成 <项目/产品线> 基础组件库草案。

范围：
- Button
- Input
- Select
- Table
- Modal
- Status Tag

要求：
- 先检查文件中是否已有同名组件。
- 不覆盖已有组件。
- 生成后给出组件清单和截图。
```

## 6. 产品/设计常用提示词

### 6.1 让 AI 看设计并总结

```text
请读取这个 Figma Frame，并用产品视角总结：
<Figma 链接>

请输出：
- 页面目标
- 用户路径
- 关键模块
- 表单字段和校验
- 状态和异常
- 需要前后端契约确认的问题
```

### 6.2 让 AI 从设计生成 PRD

```text
请结合组织 PRD Generator 规则，根据这个 Figma 页面生成 PRD 初稿：
<Figma 链接>

要求：
- 功能点使用 F-XXX
- 业务规则使用 R-XXX
- 数据需求使用 D-XXX
- 验收标准使用 AC-XXX
- 不确定的内容标记为 [待确认]
```

PRD 产物放到目标项目约定的 PRD 目录。若项目未约定，建议使用：

```text
docs/PRD/
```

### 6.3 让 AI 生成 API 契约

```text
请根据这个 Figma 页面和 PRD，生成接口契约：

Figma：
<Figma 链接>

PRD：
<PRD 文件路径>

影响端：
- <服务端>
- <消费端：后台 Web / H5 / 小程序 / App>

请根据消费方把契约放入项目约定的接口契约目录。
```

若项目未约定，建议按消费方拆分：

```text
docs/api-contracts/shared/
docs/api-contracts/admin/
docs/api-contracts/client/
docs/api-contracts/server/
docs/api-contracts/vendors/
```

### 6.4 让 AI 实现页面

```text
请使用 figma-implement-design 实现这个页面：
<Figma 链接>

目标端：<后台 Web / H5 / 小程序 / App>
目标路径：<页面路径或路由>
关联 PRD：<PRD 文件路径>
关联 API 契约：<API 契约文件路径>

要求：
- 优先复用项目现有组件和样式
- 不新增无必要依赖
- 实现后运行可用的检查命令
- 最终说明与 Figma 不一致的地方
```

### 6.5 让 AI 修改 Figma 文件

```text
请使用 figma-use 修改这个 Figma 文件：
<Figma 链接>

目标：
- 调整 <页面区域> 布局
- 增加 <字段或状态>
- 增加 <空状态/错误态/加载态>

要求：
- 先读取现有页面结构
- 分步骤修改
- 每步返回节点 ID
- 最后给截图确认
```

### 6.6 让 AI 对比设计与实现

```text
请对比这个 Figma Frame 和当前实现页面，输出差异清单：

Figma：
<Figma 链接>

实现位置：
<项目页面路径或路由>

请按以下维度输出：
- 布局差异
- 字体/颜色/间距差异
- 交互状态缺失
- 数据字段或业务规则缺失
- 建议修复顺序
```

## 7. 推荐协作流程

### 新需求从 0 到实现

```text
产品需求想法
  → AI 按组织 PRD Generator 规则追问
  → 产出 PRD
  → 设计在 Figma 出页面
  → AI 读取 Figma 补充 PRD/验收标准
  → AI 生成 API 契约
  → 研发按 Figma + PRD + 契约实现
  → QA 验收
```

### 已有设计稿转代码

```text
设计提供 Figma Frame 链接
  → AI 读取 design context + screenshot
  → AI 确认目标端
  → AI 检查项目现有组件和样式
  → AI 实现代码
  → AI 对照 Figma 截图验证
```

### 已有页面反向沉淀设计

```text
研发提供页面或代码路径
  → AI 使用 figma-generate-design 生成 Figma 页面
  → 设计审阅并调整
  → AI 提取设计系统规则或组件
```

## 8. 风险边界

### 8.1 可以直接执行的低风险任务

- 读取 Figma 并总结页面结构。
- 根据 Figma 生成 PRD 初稿。
- 根据 Figma + PRD 生成接口契约草案。
- 对比 Figma 与代码实现差异。
- 在新建或副本 Figma 文件中生成草图。

### 8.2 需要明确授权或先在副本执行的任务

- 批量修改 Figma 组件库。
- 修改设计系统变量或 token。
- 删除、重命名大量节点。
- 保存 Code Connect 映射。
- 将设计系统规则回写到组织规则仓库。

### 8.3 不建议让 AI 私自决定的事项

- 新增通用组件规范。
- 改变品牌色、字号体系、圆角体系。
- 将需求临时样式沉淀为设计系统规则。
- 为了贴近某个设计稿而绕过项目已有组件体系。

## 9. 验收清单

### 9.1 设计稿读取类

- [ ] 链接指向具体 Frame / Component。
- [ ] AI 已获取 design context。
- [ ] AI 已获取截图。
- [ ] AI 输出的不确定项已标记。

### 9.2 Figma 写入类

- [ ] 已确认目标文件和页面。
- [ ] AI 先检查现有结构。
- [ ] AI 分步骤写入。
- [ ] 每步返回节点 ID。
- [ ] 最终截图可检查。

### 9.3 设计转代码类

- [ ] 关联 PRD 明确。
- [ ] 关联 API 契约明确。
- [ ] 目标端明确。
- [ ] 复用项目组件。
- [ ] 未新增无必要依赖。
- [ ] 有运行或检查结果。
- [ ] 已说明与 Figma 的差异。

## 10. 常见问题

### 只给 Figma 文件首页可以吗？

不推荐。最好给具体 Frame、Section 或 Component 链接。只给文件首页会增加误读概率。

### 产品可以直接让 AI 改 Figma 吗？

可以，但建议先让 AI 检查结构并说明修改计划。批量改组件、变量、设计系统前，最好在副本文件中操作。

### 设计稿和项目组件不一致怎么办？

先记录差异，再决定：

- 设计稿调整到项目组件规范。
- 项目组件扩展新 variant。
- 当前需求局部适配，但记录原因。

不要让 AI 私自硬编码一套新 UI。

### AI 能不能只根据截图实现？

可以做初稿，但不推荐作为正式交付依据。正式实现应优先使用 Figma 链接，让 AI 获取 design context、截图和资产；只有截图时，变量、组件层级、Auto Layout 和真实资源都可能丢失。

### 为什么 AI 说需要先读取 design context 和 screenshot？

这是 Figma skill 的必需流程。design context 用来读取结构、变量和资源；screenshot 用来做视觉基准。两者缺一，后续实现或修改都容易偏。

### PRD 规则在哪里？

在组织规则仓库中，一般位于：

```text
Team-Intelligence-Center/Prompts/ai-prd-generator.rules.md
Team-Intelligence-Center/Prompts/ai-prd-editor.rules.md
```

如果具体项目通过 submodule、软链或编辑器规则引入组织规则，以项目 README 中的配置说明为准。

### Figma 相关通用规则在哪里？

在本机已安装 skills：

```text
~/.codex/skills/figma*
```

如果团队将 Figma 规则沉淀到组织规则仓库，应以组织规则仓库为长期维护源。

## 11. 推荐落点

| 内容         | 组织通用建议          | 项目落地说明                              |
| ------------ | --------------------- | ----------------------------------------- |
| PRD 产物     | `docs/PRD/`           | 若项目已有 PRD 目录，以项目约定为准       |
| 接口契约     | `docs/api-contracts/` | 建议按消费端、服务端、外部服务拆分        |
| 外部服务文档 | `docs/vendors/`       | 放 SDK、回调、鉴权、额度、联调说明        |
| 设计协作说明 | `docs/design/`        | 放 Figma 使用手册、设计验收规则、差异记录 |
| 项目 AI 记忆 | 项目约定目录          | 放稳定事实、决策记录、踩坑记录和 runbook  |
| 组织通用规则 | 组织规则仓库          | 不建议在每个项目重复复制                  |

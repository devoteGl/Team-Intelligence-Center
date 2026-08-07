---
schema: tic_capability.v1
id: code-investigator
status: canonical
category: discovery
activation:
  when:
    - 代码现状、调用路径、影响面或业务事实缺少证据
  not_when:
    - 当前证据已经足以安全完成任务
side_effects: read-only
artifacts:
  default: none
  when_needed:
    - 后续协作者需要可引用的现状报告
requires: []
related:
  - candidate-rule-extractor
---

# Code Investigator（代码调研技能）

## 技能用途
- 服务角色：**CI (Codebase Investigator)**
- 触发时机：代码现状、调用路径、影响面或业务规则不清，需要证据调查时
- 输出物：结构化现状报告
- 适用场景：新接手项目、老项目功能重构前、跨模块影响评估

---

## 0. 核心原则

> CI 的使命是**忠实还原系统现状**，而非评价或优化。
> 调研报告中的每一条结论，都必须有可追溯的证据来源。

**绝对禁止**：
- 凭空推测业务逻辑（无证据的推断必须标注 `[S3-推测]`）
- 省略"看不懂"的部分（看不懂 = 标注 `[S4-待补充]`，不等于跳过）
- 在调研阶段给出优化建议（那是 PM/BE/FE 的职责）

---

## 1. 调研执行流程（Standard Operating Procedure）

### 调查视角 1：目录结构扫描（宏观全景）

**目标**：形成项目整体认知地图

**执行步骤**：
1. 列出项目根目录的一级子目录及其用途
2. 识别核心源码目录（如 `src/`、`server/`、`pages/` 等）
3. 标记配置文件（`package.json`、`tsconfig.json`、`vite.config.*` 等）
4. 识别已有的文档资产（`README`、`PRD/`、`docs/` 等）
5. 标记异常信号（如：空目录、超大文件、临时文件残留）

**输出模板**：

```markdown
## 项目结构概览

| 目录/文件 | 类型 | 用途说明 | 备注 |
|-----------|------|---------|------|
| src/      | 核心源码 | 前端应用主目录 | — |
| server/   | 核心源码 | 后端服务 | — |
| PRD/      | 文档资产 | 产品需求文档 | 仅有 v4.4.318 |
| temp/     | ⚠️ 异常 | 用途不明 | [S4-待补充] |
```

---

### 调查视角 2：技术栈识别（技术基座）

**目标**：明确项目的技术选型与依赖关系

**执行步骤**：
1. 解析 `package.json`（或 `pom.xml` / `build.gradle` 等）中的核心依赖
2. 识别框架版本（Vue 2/3、React、Spring Boot 等）
3. 识别构建工具（Webpack / Vite / Maven 等）
4. 识别状态管理方案（Vuex / Pinia / Redux 等）
5. 识别 UI 组件库（Element UI / Ant Design / Vant 等）
6. 识别关键中间件或工具库

**输出模板**：

```markdown
## 技术栈清单

| 类别 | 技术 | 版本 | 备注 |
|------|------|------|------|
| 框架 | Vue | 2.7.14 | Options API 为主 |
| 构建 | Webpack | 5.x | — |
| 状态管理 | Vuex | 3.x | — |
| UI 库 | Element UI | 2.15 | — |
| HTTP | Axios | 0.27 | 封装在 src/utils/request.js |
```

---

### 调查视角 3：业务模块拆解（功能地图）

**目标**：梳理系统的功能模块边界与模块间依赖

**执行步骤**：
1. 按路由文件（`router/`）拆解页面级模块
2. 按 API 目录（`src/api/`）拆解后端服务域
3. 识别跨模块共享的组件、工具函数、常量定义
4. 绘制模块间的依赖关系（哪些模块会调用哪些 API / Store）

**输出模板**：

```markdown
## 业务模块清单

| 模块名 | 入口路径 | 核心功能 | 依赖的 API | 依赖的 Store |
|--------|---------|---------|-----------|-------------|
| 用户管理 | /user | 用户 CRUD、权限分配 | userApi | userStore |
| 订单管理 | /order | 订单查询、退款处理 | orderApi | orderStore |
```

---

### 调查视角 4：关键业务规则识别（核心抽取）

**目标**：从代码中识别隐含的业务规则

> 本阶段方法论与 `ai-prd-editor.rules.md` 第 4 节对齐

**重点扫描目标**：

| 扫描对象 | 寻找什么 | 示例 |
|---------|---------|------|
| 状态枚举（Enum / 常量） | 业务对象有哪些状态？流转规则是什么？ | `ORDER_STATUS = { PENDING: 0, PAID: 1, REFUNDED: 2 }` |
| 接口校验逻辑 | 后端拒绝了什么请求？校验了什么条件？ | `if (amount <= 0) throw '金额不能为负'` |
| 前端禁用/灰显逻辑 | UI 在什么条件下限制用户操作？ | `disabled: order.status !== 'PENDING'` |
| 错误码定义 | 系统定义了哪些异常情况？ | `ERROR_CODE.DUPLICATE_ORDER = 40001` |
| 条件分支 / Switch-Case | 不同类型/角色有哪些差异化处理？ | `if (user.role === 'admin') { ... }` |

**输出格式（候选规则 YAML）**：

> 与 `ai-prd-editor.rules.md` 第 4.1 节候选规则格式完全一致

```yaml
candidate_rules:
  - id: CR-001
    description: 已支付订单不允许修改金额
    source: backend_validation  # 来源类型
    source_file: src/api/order/validate.js:L42
    confidence: S2              # 可从代码反推的事实
    status: pending
    created_version: "当前版本号"
    notes: 来源于 updateOrder 接口的参数校验逻辑

  - id: CR-002
    description: 普通用户不可见「批量删除」按钮
    source: frontend_ui_logic
    source_file: src/views/order/list.vue:L128
    confidence: S2
    status: pending
    created_version: "当前版本号"
    notes: v-if="user.role === 'admin'" 条件渲染
```

---

### 调查视角 5：风险与异常信号标记

**目标**：识别代码中的潜在风险点

**关注维度**：

| 维度 | 关注点 | 标记方式 |
|------|-------|---------|
| 安全风险 | 敏感信息硬编码（密钥、密码）、XSS/SQL 注入点 | 🔴 高风险 |
| 技术债务 | 过时依赖、废弃代码、TODO/FIXME/HACK 注释 | 🟡 中风险 |
| 架构隐患 | 循环依赖、巨型文件（>500行）、重复代码 | 🟡 中风险 |
| 数据风险 | 缺少数据校验、缺少事务保护 | 🔴 高风险 |

**输出模板**：

```markdown
## 风险信号清单

| 编号 | 风险等级 | 文件位置 | 描述 | 可信度 |
|------|---------|---------|------|--------|
| RISK-001 | 🔴 高 | src/utils/auth.js:L15 | Token 存储在 localStorage，存在 XSS 风险 | S2 |
| RISK-002 | 🟡 中 | src/views/order/detail.vue | 文件 820 行，职责不清晰 | S1 |
```

---

## 2. 调研报告输出模板（Final Deliverable）

CI 阶段完成后，必须输出以下结构的完整报告：

```markdown
# [项目名/模块名] 现状调研报告

## 调研信息
- **调研人**：CI (AI)
- **调研日期**：YYYY-MM-DD
- **调研范围**：[说明本次调研覆盖的目录/模块范围]
- **信息可信度说明**：S1=文档事实 | S2=代码反推 | S3=合理推测 | S4=待补充

## 1. 项目结构概览
（目录结构调查输出）

## 2. 技术栈清单
（技术栈调查输出）

## 3. 业务模块清单
（业务模块调查输出）

## 4. 候选业务规则
（业务规则调查输出，YAML 格式）

## 5. 风险信号清单
（风险信号调查输出）

## 6. 关键发现摘要
（用 3~5 条要点总结最重要的发现，供 PM 快速决策）

## 7. 待 PM 决策项
（列出需要 PM 做出判断的问题，格式同 pending-decisions.md）
```

---

## 3. 调研深度控制

根据 PM 分配任务时的范围描述，CI 应自行判断调研深度：

| PM 指令关键词 | 调研深度 | 执行 Phase |
|-------------|---------|-----------|
| "快速摸底" / "大致看看" | 浅层 | 目录结构 + 技术栈 |
| "调研 XX 模块" | 标准 | 五个视角，限定模块范围 |
| "全面调研" / "完整盘点" | 深层 | 五个视角，全项目 |
| "聚焦业务规则" | 定向 | 业务规则 + 风险信号 |

---

## 4. 与上下游的衔接

### 上游：PM → CI
- PM 必须明确调研的**范围**（全项目 / 特定模块 / 特定文件）
- PM 必须明确调研的**目的**（新需求影响评估 / 重构前摸底 / Bug 根因分析）

### 下游：CI → PM
- 调查结论直接返回当前任务；只有产品方向无法从事实判断时才请求用户决策
- 后续执行者基于调查结论制定方案，决定哪些候选规则需要人工确认
- 候选规则经人工确认后，由 DS 同步至 `main-prd.md`

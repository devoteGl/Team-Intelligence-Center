---
schema: tic_skill.v1
id: candidate-rule-extractor
status: subflow
canonical: code-investigator
phase: discovery
role: CI / BE
risk_min: standard
inputs:
  - source_files
  - module_scope
outputs:
  - candidate_rules
requires:
  - code-investigator
delegates_to: []
---

# Candidate Rule Extractor（候选业务规则抽取技能）

## 技能用途
- 服务角色：**CI (Codebase Investigator) / BE (Backend Engineer)**
- 触发时机：CI 调研阶段的 Phase 4（业务规则识别）或 BE 在开发中发现隐含规则时
- 输出物：符合 `ai-prd-editor.rules.md` 第 4.1 节格式的 `candidate-rules.yaml`
- 适用场景：老项目业务规则挖掘、代码逆向工程、接口行为分析

> 对应 `ai-prd-editor.rules.md` 第 4 节：
> "你可以从状态字段、枚举值、接口校验条件、错误码、前端禁用/灰显等来源抽取候选业务规则。"

---

## 0. 核心原则

> 候选规则 ≠ 正式规则。
> 候选规则是从代码中「发现」的事实，必须经人工确认后才能转正进入 `main-prd.md`。
> AI 严禁自动将候选规则升级为正式规则。

**绝对禁止**：
- 将推测（S3/S4）直接写成确定性规则
- 遗漏规则的来源文件和行号
- 自行将候选规则写入 `main-prd.md`
- 为了让规则列表看起来更完整而编造规则

---

## 1. 抽取来源矩阵（Where to Look）

### 1.1 后端代码扫描目标

| 扫描对象 | 寻找什么 | 可信度 | 抽取示例 |
|---------|---------|--------|---------|
| **参数校验逻辑** | 接口入口处的 `if/throw`、`@Valid` 注解、手动校验 | S2 | `if (price <= 0) throw "价格不能为负"` → 规则：价格必须大于0 |
| **状态枚举定义** | `enum`、`const`、`static final` 中的状态值 | S2 | `STATUS_DRAFT=0, STATUS_PUBLISHED=1` → 规则：存在草稿→发布流转 |
| **状态流转代码** | `switch/case`、`if (status === X)` 中的状态变更逻辑 | S2 | `if (status !== DRAFT) throw "仅草稿可编辑"` → 规则：非草稿状态不可编辑 |
| **错误码定义** | 统一错误码常量文件、异常处理类 | S2 | `ERROR_40001 = "订单已取消，不可退款"` → 规则：已取消订单禁止退款 |
| **数据库约束** | `NOT NULL`、`UNIQUE`、`CHECK`、外键约束 | S1 | `UNIQUE(phone)` → 规则：手机号不可重复 |
| **定时任务 / 触发器** | `@Scheduled`、`cron` 表达式、数据库触发器 | S2 | `@Scheduled(cron="0 0 2 * * ?")` → 规则：每日凌晨2点执行数据清理 |
| **权限注解** | `@RequiresRole`、`@PreAuthorize`、自定义权限拦截 | S2 | `@RequiresRole("ADMIN")` → 规则：仅管理员可访问 |

### 1.2 前端代码扫描目标

| 扫描对象 | 寻找什么 | 可信度 | 抽取示例 |
|---------|---------|--------|---------|
| **v-if / v-show 条件** | 按钮、区块的显隐条件 | S2 | `v-if="user.role==='admin'"` → 规则：仅管理员可见此按钮 |
| **disabled 条件** | 按钮、输入框的禁用条件 | S2 | `:disabled="order.status !== 0"` → 规则：非待审核状态禁止操作 |
| **表单校验规则** | `rules` 对象、正则表达式、自定义校验函数 | S2 | `pattern: /^1[3-9]\d{9}$/` → 规则：手机号格式校验 |
| **路由守卫** | `beforeEach`、`meta.requiresAuth` | S2 | `meta: { requiresAuth: true, roles: ['admin'] }` → 规则：页面需要登录+管理员角色 |
| **常量/配置文件** | 硬编码的业务参数 | S2 | `MAX_UPLOAD_SIZE = 5 * 1024 * 1024` → 规则：上传文件最大5MB |
| **注释中的约束** | `// TODO`、`// HACK`、`// 注意：` | S3 | `// 历史原因：此处不能修改排序逻辑` → 规则：排序逻辑有历史约束 |

### 1.3 其他来源

| 来源 | 可信度 | 说明 |
|------|--------|------|
| Git Commit Message | S2~S3 | 提交信息中的业务说明 |
| Issue / Bug 记录 | S2 | Bug 修复中暴露的隐含规则 |
| 测试用例 | S2 | 测试用例的前置条件和断言 |
| 数据库现有数据分布 | S3 | 从数据分布推测业务规则 |

---

## 2. 抽取执行流程（Step-by-Step）

### Step 1：确定抽取范围

根据 PM/CI 指定的模块范围，列出需要扫描的文件清单：

```markdown
## 抽取范围

| 文件/目录 | 类型 | 预期产出 |
|-----------|------|---------|
| src/api/order/ | 后端接口 | 订单相关业务规则 |
| src/views/order/ | 前端页面 | 订单 UI 约束规则 |
| src/constants/order.js | 常量定义 | 状态枚举、错误码 |
```

### Step 2：逐文件扫描

对每个文件，按 §1 的扫描目标逐一检查，记录发现的候选规则。

### Step 3：去重与合并

同一条业务规则可能同时出现在前后端代码中（如：前端禁用 + 后端校验都约束"已发布不可编辑"）。

合并规则：
- 如果前后端一致 → 合并为一条规则，标注两个来源
- 如果前后端矛盾 → 记录两条规则，标注 `⚠️ 信源冲突`

### Step 4：评定可信度

按 `ai-prd-editor.rules.md` 第 2 节的标准：

| 可信度 | 判定标准 | 措辞要求 |
|--------|---------|---------|
| S1 | 明确存在于已有 PRD/文档 | 直接陈述 |
| S2 | 从代码/接口可直接反推 | 直接陈述 |
| S3 | 基于上下文的合理推测 | 必须用"可能/推测/疑似" |
| S4 | 无法确认 | 标注`[待补充\|需要人工确认]` |

### Step 5：输出 YAML

---

## 3. 候选规则 YAML 输出格式

### 3.1 单条规则格式

```yaml
- id: CR-001
  description: 已发布信息不可修改价格
  source: backend_validation         # 来源类型
  source_file: src/api/order/validate.js:L42  # 精确到文件和行号
  confidence: S2                     # 可信度等级
  status: pending                    # 生命周期状态
  created_version: "4.4.340"         # 抽取时所在版本
  category: 数据校验                  # 规则分类
  related_features: []               # 关联的功能编号（如有）
  notes: 来源于 updateOrder 接口的参数校验逻辑
```

### 3.2 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| id | ✅ | 全局唯一，格式 CR-XXX，递增 |
| description | ✅ | 一句话描述规则内容 |
| source | ✅ | 来源类型枚举（见下方） |
| source_file | ✅ | 来源文件路径和行号 |
| confidence | ✅ | S1/S2/S3/S4 |
| status | ✅ | pending / promoted / rejected / stale |
| created_version | ✅ | 抽取时的项目版本号 |
| category | ✅ | 规则分类（见下方） |
| related_features | 按需 | 关联的 F-XXX 编号 |
| notes | ✅ | 补充说明，如来源上下文 |

### 3.3 source 枚举值

```yaml
source_types:
  - backend_validation     # 后端参数校验
  - backend_state_machine  # 后端状态流转
  - backend_permission     # 后端权限控制
  - backend_scheduled      # 后端定时任务
  - frontend_ui_logic      # 前端 UI 约束
  - frontend_form_rules    # 前端表单校验
  - frontend_route_guard   # 前端路由守卫
  - database_constraint    # 数据库约束
  - git_history            # Git 提交历史
  - test_case              # 测试用例
  - document               # 已有文档
  - inference              # 推测（必须标注 S3+）
```

### 3.4 category 枚举值

```yaml
categories:
  - 数据校验       # 字段格式、范围、必填等约束
  - 状态流转       # 状态变更条件与限制
  - 权限控制       # 角色、操作权限约束
  - 业务流程       # 业务操作的先后顺序约束
  - 数据一致性     # 跨表、跨模块的数据约束
  - 性能约束       # 分页、限流、缓存等
  - 安全约束       # 加密、脱敏、防注入等
  - 历史妥协       # 因历史原因存在的非理想规则
```

---

## 4. 完整输出示例

```yaml
# candidate-rules.yaml
# 抽取日期: 2026-03-18
# 抽取范围: 订单模块 (src/api/order/, src/views/order/)
# 抽取人: CI (AI)

candidate_rules:

  - id: CR-001
    description: 已支付订单不允许修改金额
    source: backend_validation
    source_file: server/controller/OrderController.java:L142
    confidence: S2
    status: pending
    created_version: "4.4.340"
    category: 数据校验
    related_features: []
    notes: updateOrder 方法中，if (order.status >= PAID) throw "已支付订单不可修改金额"

  - id: CR-002
    description: 普通用户不可见「批量删除」按钮
    source: frontend_ui_logic
    source_file: src/views/order/list.vue:L128
    confidence: S2
    status: pending
    created_version: "4.4.340"
    category: 权限控制
    related_features: []
    notes: v-if="user.role === 'admin'" 条件渲染，仅管理员可见

  - id: CR-003
    description: 退款申请提交后不可撤销
    source: backend_state_machine
    source_file: server/service/RefundService.java:L89
    confidence: S2
    status: pending
    created_version: "4.4.340"
    category: 状态流转
    related_features: []
    notes: |
      退款状态流转：PENDING → APPROVED/REJECTED
      状态机中无 PENDING → CANCELLED 的转换路径

  - id: CR-004
    description: 订单列表可能按创建时间倒序排列
    source: inference
    source_file: src/views/order/list.vue:L45
    confidence: S3
    status: pending
    created_version: "4.4.340"
    category: 业务流程
    related_features: []
    notes: |
      前端未显式传递排序参数，后端默认排序逻辑未在代码中找到明确定义。
      推测基于数据库默认排序（主键递增），但需人工确认。
```

---

## 5. 候选规则的生命周期管理

> 与 `ai-prd-editor.rules.md` 第 4.1 节完全对齐

```text
pending（待确认）
  ├─ promoted（已转正）→ 写入 main-prd.md §2.2
  ├─ rejected（已驳回）→ 保留记录，附注驳回原因
  └─ stale（已过时）→ 超过 2 个版本周期未确认
```

**关键约束**：
- AI **不得**自行执行转正操作
- 人工确认后，AI 负责将规则写入 `main-prd.md` 并标注来源版本
- 被驳回的规则不删除，保留在 YAML 中作为"这不是规则"的记录

---

## 6. 与上下游的衔接

### 上游：PM → CI/BE
- PM 指定抽取范围（模块、目录、文件列表）
- PM 提供当前版本号，用于 `created_version` 字段

### 下游：CI → PM
- CI 将 `candidate-rules.yaml` 提交给 PM
- PM 组织人工评审，逐条决定 promoted / rejected
- 转正的规则由 DS 同步至 `main-prd.md`

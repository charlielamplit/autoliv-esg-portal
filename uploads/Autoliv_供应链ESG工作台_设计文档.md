# Autoliv 供应链 ESG 合规工作台 · 设计说明文档

**Supply Chain ESG Compliance Cockpit — Design Specification**

| 项目 | 内容 |
|---|---|
| 文档版本 | v0.2 |
| 日期 | 2026-07-22 |
| 读者 | 祺鲲科技内部产品 / 设计 / 前端团队 |
| 状态 | 待内部评审 → 待客户确认页面范围 |
| 关联项目 | GEN 渠道 · Autoliv 供应链 ESG 合规服务（1_Autoliv） |
| **参考设计基准** | Claude Design 项目 **ComplianceCenter**（`5aede5ad-08ed-4ae4-98c2-2dcf61dbd7ed`），以 `docs/redesign/mockups/customer-demos/sdhi/07c-global-view.html` 为主参考，设计令牌复用 `_cc-tokens.css` |
| 关联文件 | `ESG 服务平台询价需求.pptx`、`祺鲲科技一站式ESG合规服务平台介绍_202605.pdf`、`Autoliv_可持续供应链ESG合规服务.pdf`、`Autoliv_区分报价_本地vs云端.xlsx` |

---

## 1. 背景与目标

### 1.1 缘起

Autoliv 中国团队在看过我方平台介绍 PPT 中「高效赋能链主企业范围三供应链管理」一页看板后，明确提出：**希望我们提供一套类似的可视化 Dashboard / 工作台界面，主要用途是他们向自己的领导（管理层）进行汇报**。

同时客户提供了两页脱敏的内部材料，透露了关键上下文：

1. **《C-OEM ambition summary（AB/SB/SW Product）》** — Autoliv 面向的中国 OEM 客户（吉利、长城、长安、小米、蔚来、奇瑞等）各自的碳中和 / 减排 / 循环材料 / 披露等要求矩阵，按「承诺（Requirement/Commitment）/ 请求（Requirement/Request）/ 无或未知（No/Unknown）」三档状态 + 高中低优先级标注。
2. **《COEMs requests on supplier transparency, March 2026》** — 14+ 家中国 OEM（长安、长城、一汽、吉利、比亚迪、奇瑞、蔚来、小鹏、小米、理想、北汽、赛力斯、上汽通用五菱、上汽及 JAC/海马/Rox 等）对 Autoliv 提出的供应商透明度要求清单，其中已明确「要求穿透至 Tier-2，ALV 已相应提供」。

销售同事补充两点关键输入：

- **奇瑞、蔚来等 OEM 是 Autoliv 的链主**——即 Autoliv 自身也是被链主管理的供应商；
- **除 E（环境）外，OEM 链主对 Autoliv 在 S 维度（人文、权益 / 人权、劳工等）的 ESG 要求也希望纳入看板**。

> **术语约定**：本文档中「OEM 链主」指对 Autoliv 提出 ESG 要求的整车厂客户（奇瑞、蔚来等，即销售口中的"上游链主"，在要求传导方向上位于 Autoliv 上游）；「Autoliv 作为链主」指 Autoliv 对其自身约 300–400 家上游供应商的管理角色。两个方向在界面上用不同视角区分，避免混淆。

### 1.2 产品定位

这不是一页静态 PPT 的复刻，而是一个**双向视角的 ESG 汇报工作台**：

```
   OEM 链主（奇瑞 / 蔚来 / 吉利 / 长城 …）
        │  E + S + G 要求下达（碳目标、绿电、循环材料、人权劳工、披露…）
        ▼
  ┌──────────────────────────────┐
  │       AUTOLIV（承上启下）      │   ← 工作台的主角与汇报主体
  │  向上：达成 OEM 要求的进度      │
  │  自身：S1/S2/S3、SBTi 进度     │
  │  向下：管理 300–400 家供应商    │
  └──────────────────────────────┘
        │  范围三减排目标 + 统一合规标准传导
        ▼
   上游供应商（~300–400 家，分级 A–D 管理）
```

核心叙事：**Autoliv 用一个平台，同时回答"客户要什么、我们做到了多少、供应商跟上了没有"三个问题**——这正是其管理层汇报最需要的一页故事。

### 1.3 设计目标

1. **汇报优先**：默认按大屏投屏汇报场景设计，首屏 10 秒讲清全局；
2. **双向视角**：向上（OEM 要求追踪）与向下（供应商管理）两个视角在同一工作台内切换，总览页合并呈现；
3. **E+S+G 全维度**：在现有范围三（E）能力基础上，纳入 S（人权、劳工、负责任采购）与 G（披露、合规）要求维度；
4. **脱敏演示**：Demo 阶段全部使用虚构 / 脱敏数据，OEM 名单结构参照客户提供的截图，具体要求值不复现客户内部数据；
5. **可演进**：静态 HTML demo → 平台内嵌模块，信息架构一次设计到位。

### 1.4 与商务报价的关系

| 关联项 | 说明 |
|---|---|
| 询价单③ 链主服务 I（AI 问卷映射） | OEM 透明度问卷的响应状态回流至「客户要求」视图 |
| 询价单④ 链主服务 II（合规风险监测） | 「合规雷达」视图是其可视化出口（含两用物项等） |
| 平台模块 05 自动报告与看板 | 本工作台即该模块面向 Autoliv 的定制形态 |
| 链主服务定制开发起步价（¥10万/服务，占位） | 本看板若超出标准模块范围，属于该定制开发范畴——**商务口径需与销售确认** |

---

## 2. 参考基准：ComplianceCenter 设计模式复用

参考项目 `ComplianceCenter`（sdhi 山重集团 demo 系列）已经验证了一套「集团级合规驾驶舱」的完整设计语言。Autoliv 工作台**不另起炉灶，直接继承该设计系统**，仅做语义换装。模式映射如下：

| ComplianceCenter（07c-global-view） | Autoliv 工作台落位 |
|---|---|
| 顶栏（52px：品牌方块 + 产品名 + Tab 导航 + 用户区） | Shell 顶栏（Autoliv + Powered by 祺鲲；5 个 Tab） |
| 上下文栏：标题 + `scope-chip`（`GROUP · 5 BUs · 37 entities`）+ 筛选 `f-chip` 组 | 标题 + `AUTOLIV · 14 OEMs · 300+ SUPPLIERS`；f-chip = OEM 快捷筛选 / 本季度 |
| KPI strip（5 卡，`ok/warn/alert` 语义变体） | V1 总览 KPI 条 |
| **共享基线矩阵 `blmatrix`**（行=合规需求带编码，列=BU，单元格状态：继承/覆盖/缺口/不适用，尾列=一致性聚合） | **V2 OEM 要求矩阵**（行=E/S/G 要求维度带编码，列=OEM，单元格状态：承诺/请求/未知/缺口，尾列=Autoliv 达成度聚合） |
| **法规热度地图 `hmap`**（主题 × 周热度 + 当前周高亮 + 红点=直接影响）+ 本周热点 `spotlight` 深色卡 | **V5 合规雷达**主视图（E/S/G 主题 × 周热度）+ 热点卡（如 CBAM 扩围） |
| **交叉依赖图 `graph/gnode`**（中心=集团基线，围绕=BU，HOT/GAP 徽章，SVG 连线） | V1 或 V3 的**传导图**：中心=Autoliv，上方=OEM 链主节点，下方=供应商群节点（分级聚合），GAP=未达成要求 |
| 右栏三件套：`vp-adv` 顾问卡（"今天重点看 3 件事"+行动按钮）/ `fwd-item` 未来 30 天节点 / `reg-row` 法规动向 | 全站右栏：**汇报要点卡（本期 3 件事）**/ 未来 30 天（问卷截止、申报节点）/ 法规与 OEM 要求动向 |
| `_cc-tokens.css` 设计令牌 | 派生 `_alv-tokens.css`（同结构，见 §5） |

> 参考项目其余页面（06-supply-hub、07a-onboarding、07b-item-detail、07d-lifecycle、07e-shell-drawer、08-target-center 系列）分别对应本项目的供应商枢纽、要求详情抽屉、目标中心等后续页面的模式来源，M2 阶段按需取用。

---

## 3. 用户与使用场景

| 角色 | 身份 | 场景 | 关键诉求 |
|---|---|---|---|
| P1 主汇报人 | Autoliv 中国区可持续发展 / 供应链 ESG 负责人 | 月度 / 季度向管理层投屏汇报 | 一屏讲清全局，数据可信、可下钻备查 |
| P2 汇报对象 | Autoliv 中国区及全球管理层（含外方） | 听汇报、提问 | 快速抓住风险与进度，中英双语可读 |
| P3 日常使用者 | Autoliv 采购 / 客户经理团队 | 日常查看某 OEM 要求、某供应商状态 | 筛选、检索、状态更新 |
| P4（远期）供应商用户 | Autoliv 上游供应商 | 查看自己被下达的目标与评分 | 不在本期范围，信息架构预留 |

**主场景（P1/P2）硬约束**：1440 基准画布投屏、字号偏大、单页信息完整、提供「汇报模式」（隐藏操作控件、全屏、翻页导航）。右栏「汇报要点卡」直接充当汇报人的讲稿提纲——这是参考项目 `vp-adv` 顾问卡验证过的最佳实践。

---

## 4. 信息架构与页面规划

工作台共 **1 个框架 + 5 个视图**。Mockup 文件与参考项目同构组织：

```
docs/redesign/mockups/customer-demos/autoliv/
├── _alv-tokens.css                  # 设计令牌（派生自 _cc-tokens.css）
├── 00-shell.html                    # 导航框架 + 汇报模式
├── 01-executive-overview.html       # 总览驾驶舱（汇报首屏，对标 07c-global-view）★ 一期
├── 02-oem-requirements.html         # OEM 链主要求矩阵（向上视角）★ 一期
├── 02a-oem-detail.html              # 单 OEM 要求档案抽屉/详情（对标 07b-item-detail）
├── 03-scope3-management.html        # 范围三供应商管理（向下视角）★ 一期
├── 04-supplier-rating.html          # 供应商绿色分级评估
└── 05-compliance-radar.html         # ESG 合规雷达（热度图 + 法规时钟）
```

### 4.0 V0 · 框架 Shell

- **顶栏（52px，白底细分割线，沿用 `.top` 规格）**：左侧品牌方块（conic-gradient 渐变方块沿用，内嵌 Autoliv 蓝）+ 「ESG Cockpit ·  Autoliv 供应链 ESG 工作台」双层品牌字；Tab 导航；右侧数据截至日期、语言切换（中/EN）、汇报模式（Present）、用户头像。
- **主导航（5 Tab）**：总览 Overview ｜ 客户要求 Customer Requirements ｜ 供应商管理 Supplier Management ｜ 绿色分级 Supplier Rating ｜ 合规雷达 Compliance Radar。激活态沿用 `.tb.active`（水色浅底 + 深水色字）。
- **上下文栏（`.ctx`）**：页面大标题 + `scope-chip`：`AUTOLIV CHINA · 14 OEMs · 300+ SUPPLIERS`；右侧 `f-chip` 筛选组（全部 OEM / 奇瑞 / 蔚来 / 吉利 / … / 本季度），黑底激活态沿用。
- **视角色彩编码（贯穿全站）**：向上视角（OEM 要求）用 **water 水色系**；向下视角（供应商管理）用 **leaf 绿色系**；本地化/例外用 earth，风险/缺口用 alert——与参考项目语义完全一致，总览页两色并存表达"承上启下"。
- **汇报模式**：全屏、隐藏筛选与操作按钮、字号放大一档、←/→ 翻页（按 Tab 顺序）、右下角页码。

### 4.1 V1 · 总览驾驶舱 Executive Overview（汇报首屏）

**目的**：管理层 10 秒看懂「客户要求达成、自身进度、供应商管理」三线全局。整页布局直接对标 `07c-global-view.html`：主列 + 340px 右栏。

```
┌────────────────────────────────────────────────┬──────────────┐
│ KPI strip（5 卡）                               │  右栏         │
│  OEM 要求总数 · 已达成% · 30日内到期 ·           │ ①汇报要点卡   │
│  供应商覆盖率 · 范围三排放(同比)                  │  "本期 3 件事" │
├────────────────────────────────────────────────┤  +行动按钮    │
│ Sec1 · 双向传导图（graph/gnode）                 │              │
│   上排节点=重点 OEM（HOT 徽章=新要求/临期）        │ ②未来 30 天   │
│   中心节点=Autoliv（承上启下）                    │  问卷/申报节点 │
│   下排节点=供应商分级聚合（GAP=数据缺口）          │              │
├────────────────────────────────────────────────┤ ③动向流       │
│ Sec2 · 减排进度（实际 vs 目标路径）+ SBTi 双进度条 │  法规+OEM要求 │
└────────────────────────────────────────────────┴──────────────┘
```

- KPI 卡沿用 `.kp` 及 `ok/warn/alert` 变体（如「30 日内到期 12 · 其中 3 项风险高」用 alert）；
- 传导图复用 `.graph`（点阵底纹）+ `.gnode`（中心深色节点=Autoliv，`gnode.unit`=OEM 与供应商聚合节点，HOT/GAP 徽章语义沿用），SVG 曲线 + 箭头连线；
- 右栏「汇报要点卡」复用 `vp-adv` 深色渐变卡：*"本期重点 3 件事：① 奇瑞新增 Tier-1 绿电 60% 要求，影响 xx 家供应商；② 某 OEM 问卷 x 日内到期；③ 供应商数据覆盖率提升至 xx%"*，配 2–3 个行动按钮；
- 「未来 30 天」复用 `fwd-item`（日期块 + 事项 + 负责人头像），内容=OEM 问卷截止、CBAM 申报、内部汇报节点；
- 「动向流」复用 `reg-row`（新增/变更/警示 tag），内容=法规动向 + OEM 要求变化（如"奇瑞发布产业链碳中和 2047 路线图"）。

**下钻**：三段分别进入 V2 / V5 / V3。

### 4.2 V2 · OEM 链主要求矩阵 Customer Requirements（向上视角，water）

**目的**：把客户内部的《C-OEM ambition summary》和《supplier transparency requests》两页 PPT，升级为**可筛选、可下钻、可持续更新的在线矩阵**——这是客户没有、而我们能给的最大增量，也是本次需求的核心亮点。

**2a. 要求矩阵（Ambition Matrix）—— 复用 `blmatrix` 网格模式**

- **列** = OEM 客户（demo 收录：吉利、长城、长安、小米、蔚来、奇瑞、比亚迪、一汽、小鹏、理想、北汽、赛力斯、上汽通用五菱、上汽、其他；首屏显示 5–6 列 + 横向滚动/筛选）。列头沿用 `bl-h.unit` 双层结构：OEM 名 + 副标（如「AB/SB/SW 产品线」或年采购份额虚构值）。Demo 提供 `anonymize` 开关一键切换为 OEM A/B/C。
- **行** = 要求维度，沿用 `bl-row-label` 三层结构（**编码 + 名称 + 依据**），按 E / S / G 分组（S、G 组为本次新增，响应销售输入）：

| 组 | 编码（示例） | 维度 | 来源 |
|---|---|---|---|
| E | ALV-E-001 | 碳中和目标 NetZero Target | 客户截图 |
| E | ALV-E-002 | 范围 1&2 中期目标 Scope 1&2 Interim | 客户截图 |
| E | ALV-E-003 | 范围 3 中期目标 Scope 3 Interim | 客户截图 |
| E | ALV-E-004 | 可再生能源 Renewable Energy（如奇瑞：Tier-1 供应商 2030 年 60% 绿电） | 客户截图 |
| E | ALV-E-005 | 循环材料 Circularity（再生/生物基/可回收，如再生铝镁合金） | 客户截图 |
| E | ALV-E-006 | 质量平衡 Mass Balance | 客户截图 |
| S | ALV-S-001 | 人权与劳工 Human Rights & Labor（尽调、行为准则、冲突矿产） | 销售新增，占位待客户补充 |
| S | ALV-S-002 | 负责任采购 Responsible Sourcing（EcoVadis / RBA 类评估） | 销售新增，占位待客户补充 |
| G | ALV-G-001 | 第三方披露 3rd-Party Reporting（CDP 等） | 客户截图 |
| G | ALV-G-002 | 数据透明度 Data Transparency（穿透至 Tier-N） | 客户截图 |
| G | ALV-G-003 | 付费意愿 Willingness to Pay | 客户截图 |

- **单元格状态**（融合客户 PPT 图例与参考项目 `bl-cell` 状态体系）：

| 状态 | 视觉（沿用 bl-cell 变体） | 语义 |
|---|---|---|
| 承诺 Commitment | `shared`（leaf 渐变底 + 深色 cstate 标签） | OEM 已正式要求/承诺 |
| 请求 Request | `overridden`（earth 渐变底） | OEM 提出但未强制 |
| 未知 Unknown | `none`（灰底 — 占位） | 无要求或未知 |
| **缺口 Gap** | alert 渐变底 + ⚠（参考项目 row 5 样式） | OEM 有要求而 **Autoliv 尚未响应** |

  单元格内三行信息沿用：状态标签 `cstate` + 责任人 `cown`（Autoliv 侧 owner）+ 备注 `cnote`（要求摘要/截止年份，差异项用 `cnote.diff`）。优先级 High/Med/Low 以角标圆点呈现。
- **尾列聚合**：参考项目的「一致性」列 → 换语义为 **「达成度」**（`bl-agg`：大数字 % + 说明如"4 达成 + 1 缺口"）。
- **交互**：单元格点击 → 右侧抽屉（02a：要求原文中英、生效/截止时间、优先级、Autoliv 响应状态与责任人、关联证据）；列头点击 → 该 OEM 全部要求档案；筛选 E/S/G、状态、优先级。矩阵下方沿用 `bl-legend` 图例条 + "显示 n / N 项 · 查看全部 →"。

**2b. 透明度要求追踪（Transparency Tracker）**

对应《COEMs requests on supplier transparency》页：按 OEM 逐行列出问卷 / 数据穿透要求（Tier-1/Tier-2/Tier-n 深度徽章）+ 响应状态（已提交 / 进行中 / 逾期 / 未启动）+ 截止日期，样式复用 `reg-row` + 状态 tag。未来由「链主服务 I（AI 问卷映射）」的实际工单数据驱动。

### 4.3 V3 · 范围三供应商管理 Supplier Management（向下视角，leaf）

**目的**：现有 PPT slide「高效赋能链主企业范围三供应链管理」的交互化升级——客户正是看中这一页，布局与信息保持"所见即所得"，但视觉细节全面换装为 ComplianceCenter 设计语言（卡片、字体、令牌）。

**保留并交互化的元素**：
- 五步能力条：01 供应商碳数据采集 → 02 范围三排放核算 → 03 减排目标分解下发 → 04 绿电/绿证管理 → 05 自动报告与看板（点击高亮对应下方数据区）；
- KPI 卡（`.kp`）：范围三总排放量（tCO₂e，同比）、绿电使用比例、供应商覆盖率；
- 范围三排放结构环形图（类别 1 采购商品 / 类别 2 资本商品 / 类别 3 燃料及能源 / 类别 4 上游运输 / 类别 5 废弃物 / 其他）——**demo 数值改用贴近 Autoliv 结构的虚构值（采购材料占比最高，呼应其"75% 为采购材料"的公开事实），不用 PPT 原数**；
- 减排进度看板（实际 vs 目标路径折线）；
- 底部流程带：统一标准 → 目标传导 → 过程跟踪 → 一站式达成。

**新增**：供应商清单表（搜索/筛选：代号、类别、数据状态、绿电比例、评分、目标接收状态），行点击 → 供应商档案（demo 做 2–3 家即可，模式对标 07b-item-detail）。

### 4.4 V4 · 供应商绿色分级 Supplier Rating（leaf）

- 沿用现有 slide 右栏体系：评分 0–100 → 等级 **A(90–100) / A-(80–89) / B-(70–79) / B(60–69) / C(40–59) / D(0–39)**，色带 leaf→earth→alert；
- 分级分布直方图（300+ 家概览）+ 供应商卡片列表（绿电 %、评分、等级徽章、认证标签：科学碳目标 / 碳足迹认证 / CBAM 报告 / 待完善认证）；
- **新增 S 维度标签**：行为准则签署、人权尽调问卷完成——呼应"OEM 对 Autoliv 的 S 要求需向下传导至供应商"的逻辑闭环；
- 底部保留「绿色评分综合评估 · 动态分级 · 持续提升」方法论说明条。

### 4.5 V5 · ESG 合规雷达 Compliance Radar

**目的**：承接询价单④「合规风险监测」，回答汇报中"我们面临什么外部合规压力"。

- **主视图＝热度地图**（复用 `hmap`，主题 × 周，当前周高亮，红点=对 Autoliv 直接影响）。主题行按 E/S/G 划分：环境·碳（CBAM/碳足迹/绿电）、循环与材料、**人权·劳工（CSDDD、行为准则）**、贸易·出口管制（**两用物项**）、披露·治理（CSRD/CDP/Catena-X）；
- **热点卡**（复用 `spotlight` 深色卡）：如"CBAM 扩围信号 · 影响 xx 类产品 · 建议启动评估"；
- **法规时钟带**：横向时间轴列出 CBAM 正式征收、CSRD 分批适用、CSDDD 尽调义务、Catena-X/电池护照、中国产品碳足迹体系、两用物项出口管制关键节点（沿用《客户预研简报》"法规压力时钟"素材）；
- 右栏动向流复用 `reg-row`。Demo 阶段静态示意，数据均为示例。

---

## 5. 视觉设计规范

### 5.1 设计令牌（`_alv-tokens.css`，派生自 `_cc-tokens.css`）

**直接复用参考项目全部令牌**（色阶、圆角、阴影、字体栈），不改值、只加语义别名——保证两个 demo 系列视觉同源、组件可直接搬运：

```css
/* 复用：water / leaf / earth / alert / ink / paper 全色阶（值同 _cc-tokens.css） */
--water-500:#0891B2;  /* 向上视角主色 · OEM 要求（兼有 Autoliv 蓝的气质） */
--leaf-500:#3FAE55;   /* 向下视角主色 · 供应商管理 · 达成/正向 */
--earth-500:#C97D1C;  /* Request 状态 · 本地化/例外 */
--alert-500:#DC3A2C;  /* 缺口 · 逾期 · D 级 */
--ink-900:#0F1E24;    /* 主文字 · 深色卡底 */
--paper-warm:#F7F9F9; /* 页面底色 */

/* 新增语义别名 */
--upstream: var(--water-500);    /* OEM 链主向 */
--downstream: var(--leaf-500);   /* 供应商向 */
--grade-a: var(--leaf-600); --grade-b: var(--earth-300);
--grade-c: var(--earth-500); --grade-d: var(--alert-500);
```

圆角（card 10px / banner 14px / chip 999px）、三级阴影、`.btn/.btn.primary/.eyebrow/.f-chip` 等基础组件规格全部沿用。

### 5.2 字体与双语规则

- 字体栈沿用参考项目：正文 `Plus Jakarta Sans + Noto Sans SC`；数字 `Manrope`（tabular-nums）；编码 `JetBrains Mono`（要求编码 ALV-E-001 等用 mono，同 `req-code` 模式）；
- Google Fonts CDN 引入；**离线演示场景**（客户内网投屏）需在 M1 交付时内嵌 woff2 子集或降级系统字体栈，作为构建选项；
- **双语层级**：中文为主标题，英文为辅注（小一档、`--ink-500`），如「客户要求 *Customer Requirements*」；KPI 数值单位保持英文（tCO₂e、%）；OEM 名称用英文官方名；语言切换为两套标签字典（JS 对象），服务外方管理层场景。

### 5.3 版式

- 基准画布 **1440px 宽**（同参考项目 `.stage`），主体 `grid: 1fr 340px`（主列 + 右栏）；顶栏 52px、上下文栏、内容区 padding 沿用参考规格；
- 投屏适配：1440 基准在 1080p/4K 投屏下等比缩放；汇报模式下 KPI 主数值再放大一档；
- 图表遵循 dataviz 内部规范（单色系渐变优先、网格线弱化）；热度色阶沿用参考项目 h0–h5 六档。

---

## 6. 数据模型（Demo 阶段）

Demo 为单文件 HTML 内嵌 JSON。核心实体草案：

```js
// OEM 链主
oem: { id, name, nameEn, logo, anonymousCode /* "OEM A" */, tierDepthRequired /* 1|2|n */ }

// OEM 要求条目（矩阵单元格）
requirement: {
  id,                   // "ALV-E-004"
  oemId,
  pillar: "E" | "S" | "G",
  dimension,            // netzero | s12_interim | s3_interim | renewable | circularity |
                        // mass_balance | human_rights | responsible_sourcing |
                        // reporting_3rd_party | transparency | willingness_to_pay
  status: "commitment" | "request" | "unknown",
  priority: "high" | "med" | "low",
  detail, detailEn, dueYear,
  response: { status: "done" | "in_progress" | "gap" | "not_started", owner, evidence }
}

// 透明度问卷/穿透要求
transparencyRequest: { id, oemId, type, tierDepth, dueDate, responseStatus }

// 供应商（向下）
supplier: { id, codeName, category, score, grade /* A|A-|B-|B|C|D */,
            greenPowerPct, dataStatus, certs: ["SBTi","PCF","CBAM"],
            social: { codeOfConductSigned, hrddDone },
            targetReceived }

// 排放与进度
emissions: { scope3Total, byCategory: {...}, trend: [{year, actual, target}] }
```

**脱敏原则**：
1. OEM 维度：demo 默认展示真实 OEM 英文名（来自客户自己提供的截图，属客户已知信息），但所有**要求内容、状态、优先级均为虚构示例**，页脚注明 *Demo data — for illustration only*；`anonymize=true` 开关切换为 OEM A/B/C；对外场合（如经 GEN 转发）一律匿名模式。
2. 供应商维度：全部虚构（供应商 A/B/C…），不出现任何真实供应商名。
3. 排放数值：不复用 PPT 原数，也不使用 Autoliv 公开报告的精确数字，用量级合理的虚构数。

---

## 7. 技术实现

| 项 | 决策 | 说明 |
|---|---|---|
| Demo 形态 | 单文件 HTML / 视图 + 共享 `_alv-tokens.css` | 与参考项目同构；可离线打开、直接投屏、便于传给客户 |
| 图表 | **纯 HTML/CSS/SVG 优先**（同参考项目做法） | 矩阵、热度图、KPI、传导图均为 HTML/SVG 手绘，保证风格与还原度；环形图/折线可用内联 SVG 或 ECharts（二选一，M1 定） |
| 交互 | 原生 JS，无框架 | 抽屉、筛选、语言切换、匿名开关、汇报模式 |
| 存储 | 无（内嵌 JSON） | demo 不落任何真实数据 |
| 产出同步 | mockup 完成后同步回 Claude Design 项目 `ComplianceCenter` 或新建 `AutolivCockpit` 项目 | 与 sdhi 系列并列为 customer-demos 的第二个客户目录 |
| 演进路径 | demo → 平台内嵌模块 | 上线后数据源切换为平台 API（问卷工单、供应商数据、核算结果）；本地部署方案下随链主账号一并交付 |

---

## 8. 里程碑

| 阶段 | 内容 | 出口 |
|---|---|---|
| M0 本文档 | 设计说明评审，与销售对齐商务口径 | 内部确认页面范围 |
| M1 核心三页 demo | V1 总览 + V2 OEM 矩阵 + V3 供应商管理（含 shell 导航） | 交 Autoliv 对接人预览，收集反馈 |
| M2 完整 demo | 补 V4 分级、V5 合规雷达、02a 详情抽屉、汇报模式、双语切换 | 支撑客户向管理层的首次正式汇报 |
| M3 平台化 | 接平台真实数据，随链主账号交付（云端 / 本地均适用） | 对应报价中的定制开发工作量 |

---

## 9. 开放问题（需确认）

**问客户（经销售/GEN）：**
1. OEM 要求矩阵中被遮挡的明细（各 OEM 的具体要求文本、优先级）能否提供脱敏版，用于把矩阵填实？
2. S 维度要求的具体形态：OEM 是通过行为准则签署、EcoVadis/RBA 评估、人权尽调问卷还是审计提出？希望追踪到什么粒度？
3. 汇报频率与形式（月度/季度？投屏还是发 PDF？汇报对象是否含瑞典总部）——决定汇报模式与英文版优先级；
4. Demo 中 OEM 是否可用真实名称（仅限其内部使用），还是从一开始就匿名？

**问内部（销售/产品）：**
5. 本定制看板的商务归属：计入「链主服务 I/II 定制开发起步价」还是单列？
6. V5 合规雷达中两用物项/出口管制监测的数据源与更新机制，产品侧现状如何？
7. Demo 阶段品牌呈现：突出 "Powered by 祺鲲"，还是按 Autoliv 内部工具风格弱化我方存在感？

---

## 附录 A · 客户脱敏截图素材映射表

**A1. 《C-OEM ambition summary（AB/SB/SW Product）》可辨认信息**（中部被遮挡，以下仅为边缘可见部分，demo 不直接复现）：

| OEM | 可见要点 |
|---|---|
| Geely 吉利 | NetZero 2045；S1&2 中期 2030；第三方披露有动作（与 C 字头机构合作，被遮挡） |
| GWM 长城 | NetZero 2045；制造碳强度降 18%（年份被遮挡） |
| Changan 长安 | NetZero 2045；2027 CO₂e 达峰 |
| Xiaomi 小米 | NetZero 2050；2030 较 2021 降 30%，2040 碳中和（部分被遮挡） |
| NIO 蔚来 | 碳排放降 43%（基准与年份被遮挡） |
| Chery 奇瑞 | NetZero 2047；单车制造排放 2030 降 60%（基年 2023），运营碳中和 2037；产业链碳中和 2047；**Tier-1 供应商 2030 年绿电 60%**；推广再生铝镁合金用于方向盘（SW）；"Green Life"可持续活动（IUCN 合作、UNGC 成员）；要求 Tier-1 供应商推进碳目标管理 |
| 图例 | 深绿=Commitment，浅绿=Request，黄=No/Unknown；优先级 High/Med/Low 圆点 |
| 行维度 | Kg CO₂e Footprint（NetZero / S1&2 / S3 interim）、Renewable Energy、Circularity（Recycled/Bio-/Recyclable）、Other（Marketing / Supply deals / Mass Balance / 3rd Party Reporting / Willingness to pay） |

**A2. 《COEMs requests on supplier transparency, March 2026》可辨认信息**：BU 维度列出 Changan、GWM、FAW、Geely、BYD、Chery、NIO、Xpeng、MI、Lixiang、BAIC、Seres、SGMW、SAIC、其他中国 OEM（JAC、海马、Rox 等）；明细被遮挡；末行可见「Required Tier-2. ALV provided it accordingly」——**证明穿透式（Tier-2+）数据要求已是现实**，是 V2b 透明度追踪器的直接依据，也是向下（V3/V4）供应商数据采集必要性的最好论据。

## 附录 B · 双语术语表（界面用）

| 中文 | English |
|---|---|
| 供应链 ESG 合规工作台 | Supply Chain ESG Compliance Cockpit |
| 客户要求 | Customer Requirements |
| 供应商管理 | Supplier Management |
| 绿色分级 | Supplier Rating |
| 合规雷达 | Compliance Radar |
| 要求矩阵 | Ambition Matrix |
| 透明度追踪 | Transparency Tracker |
| 承诺 / 请求 / 未知 / 缺口 | Commitment / Request / Unknown / Gap |
| 达成度 | Fulfillment |
| 范围三总排放量 | Total Scope 3 Emissions |
| 绿电使用比例 | Renewable Electricity Share |
| 供应商覆盖率 | Supplier Coverage |
| 目标路径 / 实际进度 | Target Path / Actual Progress |
| 人权与劳工 | Human Rights & Labor |
| 负责任采购 | Responsible Sourcing |
| 汇报模式 | Presentation Mode |

---

*本文档由祺鲲科技编制，demo 所涉数据均为示例，不代表 Autoliv 实际数据。*

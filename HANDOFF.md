# Handoff — Autoliv ESG Cockpit

供应链 ESG 合规工作台，服务外方管理层。主体是单文件 DC：`Autoliv ESG Cockpit.dc.html`（模板 + 逻辑类 `Component`，**6889 行 / 768KB**）。

同目录另有两个独立 DC 页，不共享 `Component`：
- `ASSI 线上供应商可持续问卷.dc.html` —— 供应商视角的 133 题问卷，题库在 `assi-data.js`（`window.ASSI` 的 `QS/PIL/INFO/DEMO/HIST`）。**工作台用 iframe 内嵌它**（供应商问卷的 ASSI 标签页），所以这个文件名被硬编码在 cockpit 里，改名前先改那处 `<iframe src>`。
- `Autoliv Demo 页面框架.dc.html` —— 信息架构梳理讲解页，纯静态。

部署侧（三个入口页、`.vercelignore` 的坑、同步自检清单）见 `README.md`，本文只讲实现。

## 设计基准
- 参考 ComplianceCenter（`/projects/5aede5ad-08ed-4ae4-98c2-2dcf61dbd7ed/docs/redesign/mockups/customer-demos/sdhi/07-compliance-center.html`）：224px 左侧边栏 + 顶栏面包屑 + 卡片语言 + water/leaf/earth/ink token。
- Autoliv 海军蓝 `#002D6B` 作品牌层。绿=达标、橙=进行、红=缺口。
- 字体：Plus Jakarta Sans / Manrope(数字) / Noto Sans SC / JetBrains Mono(编码)。
- **全内联样式**；helmet `<style>` 仅放 reset + 属性选择器开关（view/oem/lang/anon/drawer 切换）。

## 第八轮：V1 总览驾驶舱重做（2026-08-03）
新增 `v1Vals(s,zh)` 一个方法（+218 行），V1 整屏换掉。**这是清掉了「总览驾驶舱随新增内容更新」那条老待办。** 无新视图 / 抽屉 / 资源引用。

### 屏结构（自上而下）
1. **价值链合规达成度**：`vcPct = selfPct×0.4 + chainPct×0.6`。`selfPct` = 客户问卷已自答比例（`(112-todoN)/112`），`chainPct` = 全链达标比例（`chainOk/chainTot`）。整屏状态灯 `overall`：稀土窗口 ≤120 天 → `bad`，否则有待补项 → `warn`，全清 → `ok`。
2. **三条紧急事项**（`v1Urgent`）：稀土敞口倒计时 → v8 · 47 家高风险待帮扶 → v7 · 67 家未回传导 → v12。
3. **两个需求来源**（`v1Src`）：客户要求（4 份在办）→ v2 · 法规与管制（16 条义务）→ v6。**并列呈现是刻意的** —— 文案写明「两条都是必须响应的来源」。
4. **五段主线**（`v1SpineRest`，第 1 段"需求来源"由上面的卡承担，模板只渲染 2–5 段）：自身响应 → 向上游传导 → 监督上游回填 → 达成。每段带指标行 + 直达按钮。
5. **管理 KPI · 汇报口径**（新卡）：`v1Mgmt` 五个率（接入 / 填报 / 证据完整 / 准时 / 采购额碳覆盖）· `v1Deliv` 四类交付物 · `v1Risk` 四个风险计数 · `v1Drill` 五个下钻维度（客户 / 零件 / 材料 / 工厂 / 区域）。

### 要注意的点
- **稀土倒计时读的是 `reg_demo.json`**：`regulations` 里 id 为 `RARE` 的那条 + `calendar['2026']` 里含"稀土"的条目，正则取 `MM-DD` 拼成 `2026-MM-DD`，取不到时兜底 `11-10`。**`regPack` 没到时用的就是兜底值**，首帧倒计时可能与稳态不一致。
- **`rareDays` 用 `new Date()` 实时算**，所以这个数字**每天都在变**，演示截图对不上是正常的。
- **`s.v1Base` 是个只读的覆盖钩子**：`const B=s.v1Base||{}` 提供了 `srvPacks/packs/tasks/back/chainOk/late/notCascaded/highRisk/registered/evOk/onTime/spendCov/spend/capLate/certDue/anomaly` 等十几个基数的默认值，但**全库没有任何地方给 `v1Base` 赋值**。要接真实数据，往 state 里塞 `v1Base` 即可，不必改 `v1Vals`。
- 回流态 `s.reflow` 会微调数字（已回 +1、逾期 −4、未回传导 −7、全链达标 +1），保持与导览故事一致。

### 本轮留下的死代码（**不要当 bug 修，但也别再往上加东西**）
V1 换屏后，旧屏的几处计算还留着，只是没有模板在渲染：
- `mainlineVals(s,zh)` 仍在 `renderVals()` 里被展开，但 `mlStages` / `mlLoopZh` / `mlLoopCta` / `mlLoopGo` 在模板中**引用次数均为 0** —— 第四轮那条「5 格主线流水线」已被本轮的 spine 取代。
- `kpis:this.kpiData(s.oem)` 仍在算，`{{ kpis }}` 模板中已无引用（旧 5 KPI 行）。`kpiData()` 本身还被别处用，别删函数。
- `go11` 仍有定义，模板引用为 0。
清理它们是安全的，但属于独立的一次瘦身，别混在同步里做。

## 第七轮：法规包外置 + V14 单项要求管理（2026-08-03）
两件事：法规内容从硬编码搬进数据包；给"一条要求"开了独立的执行台账屏。

### 新数据包 `data/reg_demo.json` → `state.regPack`
第四个运行时 fetch（`meta` / `regulations[16]` / `businessNodes[7]` / `calendar` / `exportControl`）。
单条 regulation 的字段：`id, name, nameEn, category(C1/C2/C3), view, inPlatform, impactStar, urgency, statusColor, autolivStatus, coreRequirement, impactAutoliv, supplierRequirement, deliverable, agent, collectedBy, keyDates, relatedReq37, businessNodes`。

- **`regFromPack(r,zh)`** 把一条 pack 记录适配成 reg 抽屉的形状：紧迫度 / 入库状态（新增·部分覆盖·已在库）/ 星级 / 红黄绿状态语义 / 市场标签（按正则从文案里认 欧盟·美国·德国·中国出口管制）/ C1-C3 的判定依据（规模门槛 · CN-HS 编码逐零件 · 物项归类逐交易）。
- **抽屉是"包优先、旧表兜底"**：`kind='reg'` 先按 `id`/`name` 在 pack 里找，找不到才回落到硬编码的 `regDetail()`（`regFromPack(pk) : regDetail()[dwKey] || regDetail()['CBAM']`）。所以 **`regDetail()` 不能删** —— 它既是兜底，也仍被 `reqOrigin()` 用来反查"哪条法规引用了这条要求"。
- **`dimsOf(r)`** 按正则给法规打 5 个维度标签：`reg` 罚则/禁令类 · `oem` 客户传导类 · `std` 标准与数据载体（IMDS/CMRT/SCIP/EcoVadis…）· `own` 能映射到自有 37 项的 · `geo` 地缘与出口管制（含 `category==='C3'`）。v6 的筛选就是按它切的（`regDim`，另有 `regCat/regSt/regStar/regNew`）。
- **`reqNosOf(list)`** 解析 `relatedReq37` 里的 `#5–#8` / `#12` 这类写法（支持 `–`/`-`/`~`/`至` 四种连接符）成要求号数组并去重。法规 ↔ 37 项要求的关联全走它。

### V14 单项要求管理（`data-screen-label="V14 单项要求管理"`）
**一条要求 × 327 家的执行台账**。入口只有一个：要求详情里的 `toManage`（`setState({view:'v14',r14No:x.no,r14Fil:'all',r14Sel:{}})`），面包屑显示 `单项要求 · REQ-xx`。

- 名单构成刻意写死为 327：`s.sup` 的 317 家问卷在册 + 从 `supplierRaw()` 里补未被本年度问卷覆盖的 10 家（**跳过 `isNew`**，刚准入的不算）。按采购额降序。
- 九种行状态 `S{}`：达标分 证据齐全/证据将过期/复核中，未达标分 部分达标/整改中/无计划，另有 未回收/已交待判定/未发起。
- 支持筛选（`r14Fil`）+ 多选（`r14Sel`，全选 `r14ToggleAll`）后批量催办 / 帮扶 / 整改 / 豁免，以及导出。

### 口径收敛（延续第六轮的思路）
- **`reqCov(x)` 成了覆盖数的唯一定义** —— 上一轮记的"公式散在两处"隐患已消除（见「关键实现注意」第 12 条已改写）。规则：**由本年度气候问卷承接或判定的要求（`no===1` 或命中 `measMap()`）一律返回 317**，与 V7 的 317 家同源；其余才走 `Math.max(96,327-((no*37)%118)-(期望项再减42))`。
- **`measMap()`** 缓存"要求号 → 9 道已测量问卷题"的映射（从 `sdQStats()` 的 `'REQ #7'` / `'REQ #19/20'` 文案里解析）。注意它缓存在 `this._measMap` 上，且**不依赖异步数据**（`sdQStats()` 是内联的），所以这里按实例缓存是安全的 —— 与 `supCompliance()` 必须带 `reqs.length` 的情况不同。
- **`reqCompliance(s,zh,x,cov)`** 单项要求的达标详情，注释写明「与达标全景(v7)同一份数据与同一套映射，保证两处口径一致」。有判定的给出判定来源/证据要求/复核方式；没判定的三行全部标红或灰，并给「到全量要求里挂上判定规则」的跳转。
- **`reqOrigin(x,zh)`** 要求来源：先按硬编码的 `oemNos` 判断是"客户要求归并"还是"Autoliv 自有承诺"，再追加引用了它的法规名（取前 2 条）。

### 第七轮补丁（同日）：V6 卡片合并 + 筛选项加悬停释义
接上条法规包外置之后的一次纯布局收敛，无新方法、无新资源引用（6689 → 6671 行）。

- **卡片从 6 张减到 4 张**：「影响强度矩阵 · 压力从哪来」不再是独立卡，**并入「法规义务库」的筛选条**，变成一排「压力来源」chip（`regDims`）；「合规时间日历」提到 V6 最上方并改名「合规时间日历 · 什么时候到」，加了「最近三个硬节点」（`regCalNext`）。日历没被删，`regCal*` 仍在用，`reg_demo.json` 的 `calendar` 键照旧。
- **筛选条现在一处集齐**：类别 `regCatChips` · 状态 `regStChips` · 压力来源 `regDims` · 清空筛选 / 全部收起 / 全部展开。
- **状态与维度都加了悬停释义**：`stTip{}` 解释红黄绿的处置含义（红=触发采购与合规升级 · 黄=可暂用但自动生成整改任务 · 绿=可直接提交），每个维度 chip 的 `tip` 拼出「影响强度 x/5 · 紧迫 y · 只看这类压力驱动的 N 条义务」。卡上留了一行「状态含义见筛选项悬停说明」作指引。
- 选中态样式改用 class `dimsel` + helmet 新增 `.rowlink.dimsel:hover{background:#1E3340 !important}` —— 内联样式盖不住 hover，必须走 helmet（同「关键实现注意」第 9 条的道理）。

### ASSI 页（`assi.html`）第七轮改动：切换支柱后回到顶部
`toTop()` + `topRef`。除了 `window.scrollTo` 与 `documentElement/body.scrollTop`，还**沿 `parentElement` 向上找所有 `overflow-y:auto|scroll` 且真的溢出的祖先并逐个归零** —— 因为这个页面会被工作台用 iframe 内嵌，滚动容器可能在外层。整段包在 `try/catch` 里。

## 第六轮：供应商达标口径统一 + 引入中候选池（2026-08-02）
这轮的主题是**把"供应商好不好"的口径收敛成一个函数**，别处一律引用，不再各屏各算。

- **`reqCats()`** —— 五类要求的单一定义（英文 key ↔ 中文 ↔ 主题色）：治理框架 `#5B3FA8` · 气候与循环 `#0B5B4A` · 负责任经营 `#0B3A82` · 安全与包容职场 `#A3620F` · 道路安全 `#B0291D`。key 用英文，因为要和 `state.reqs` 里的 `r.category` 对上。
- **`supCompliance(code)`** —— 唯一的评分口径：37 项要求逐项判定，**硬性/新增 ×3、期望 ×1 加权**，分数 = 加权通过率，分级 `A ≥85 / A− ≥76 / B ≥66 / B− ≥58 / C ≥44 / D`。返回 `{score,grade,pass,tot,hardMiss[],cats[]}`。达标与否由 `(code 哈希 ^ 要求号)` 对 `sup.cbase`（缺省取 `sup.score`）取模决定 —— 确定性，同一家每次刷新结果一致。
  - **缓存键必须带 `reqs.length`**（`this._compCache[code+':'+reqs.length]`）：`state.reqs` 是异步 fetch 到的，要求集没到时函数返回 0 分，若按 code 单独缓存会把 0 分永久钉住。要求集为空时直接返回空壳且**不写缓存**。
  - 三处调用（v3 列表行、供应商抽屉、候选抽屉）共用它，数字不会互相打架。
- **`sd37Vals()`（v7）「37 项要求达标全景」** —— 把 37 项要求按**三态**分档，每项只出现在一处：
  - `meas` 已测量：今年问卷收了逐题回答，能算达标率（家数 + 采购额加权双口径），行可点下钻缺口名单；
  - `cov` 仅有回收：发下去也收到回执，但没设逐题判定，只有覆盖率没有达标率。判定"是否 cov"的阈值是回收 ≥200 家。（回收数当时在 `sd37Vals` 与要求抽屉各写了一遍，**第七轮已提取成 `reqCov()` 单一定义**，以那个为准。）
  - `none` 本周期未发起：点击跳 v13 并提示"到全量要求里挂判定口径"。
  - 文案上明确写了"这不是数据缺失，是管理上还没开始测" —— 演示时这条是口径诚实性的关键，别删。
- **`cands()/candSeed()/candVals()` 引入中候选池** —— v3 新增分段控件 `state.v3Seg`（`active` 在册 / `cand` 引入中）。候选企业**已建档但未准入**：没有评分、没有分级，且**不计入 `supplierRaw()` 的在册家数、达标率分母与分级分布**（这条在 `candNote` 里对用户明写）。
  - 三条 seed（SUP-1974/1977/1980）覆盖 stage 0/1/1 三种态：待发起自评 / 等回卷（含"已读未回填"与"未读"两种细分）/ 已回卷待准入。
  - 新增第 11 类抽屉 `kind='cand'`（`.dwd.cd`）：5 步引入尽调时间轴，其中审核方式由 `supCompliance` 的分数决定（<58 现场审核 / <76 文件审核 / 否则免审）。准入后写入 `supplierRaw()` 并带 `isNew:true`、`cbase:60`。
  - **`isNew` 的用途**：`supCasNos()` 见到 `isNew` 直接返回空数组 —— 刚准入的供应商没经历过任何一轮下发，不能凭分数编出"在办条目"。
- **v3 卡头改名**：「供应商基准清单」→**「供应商主数据清单」**（第四轮的旧名已废）。分级分布卡加了「A/A− N 家 · 要求达标良好 / C/D N 家需介入」。

## 第五轮：V11 客户问卷改三段式 校卷 → 作答 → 交卷（2026-08-02）
`state.srvTab` 驱动三个阶段（`check` / `answer` / `score`），阶段条上的角标数字全部由下面同一套桶模型算，不会漂。

- **① 校卷 `srvCheckVals()`** —— 解决"AI 把题读错了怎么办"。质检卡四类：题号连续（112 题无跳号）· 疑似重复（题干完全相同，多半是原件合并单元格串行）· AI 未能可靠识别（无指引且无法归类）· 缺客户作答指引（不阻塞，仅提示）。
  - 逐题可「标题面正确」（`srvQOK`）/「修订题面」（`srvQTxt`，草稿态 `srvQEd`）/「对照客户原文」（`srvQOr`）。**修订后的题面仅内部展示，导出给客户时仍用原文** —— 这是刻意的，别在导出里换成修订版。
  - 出口两个：`srvLock()` 锁定题面（存疑项未清零时不放行，会切到存疑列表并 toast）→ `srvLocked`；或 `srvSkipCheck()` 跳过 → `srvSkipped`，代价是第 ③ 步校验里会挂一条「卷面未经复核」。
  - 列表**只渲染前 40 题**，超出提示"用上方质检卡切换范围"。
- **② 作答** —— 沿用既有的 AI 预填 + 人工确认（`srvA` 答案 / `srvS` 支持信息 / `srvF` 佐证文件 / `srvOK` 已确认 / `srvNA` 不适用与等待记录）。
- **③ 交卷 `srvSubmitVals()`** —— 六条校验，分**硬（阻塞提交）**与**软（需说明）**：
  - 硬：未作答 · 未确认（AI 填的没人拍板）· 空心的「是」（答是但无支持信息，客户抽查无法举证）；
  - 软：红线未达标（最低要求项答否，须附整改计划）· 等供应商/客户回 · 卷面未复核或不适用没写理由。
  - 每张校验卡可点，直接跳回 ② 并预置 `srvFilter` 到对应队列。
  - **「等别人回」给了两个出口**：`chase` 催办（把承诺回期改到 2026-08-25 并留痕）、`fallback` 兜底作答（以"暂无数据 + 行动计划 + 预计补交时间"如实答 `no` 并自动确认，从此不再阻塞提交）。这是这轮的设计要点——不让"等回复"变成死锁。
  - 硬项清零后才出「提交给客户」；若仍有等待项，另给「部分提交」（先交 N 题、声明 M 题待补）。回执写在 `srvSubmitted`。**导出不受阻塞限制**（`subGateZh` 里明写"导出不受限"）。
- **`exportSurvey(qs,zh,filled,…)`** —— 空白卷 8 列 / 答卷 12 列（多作答、支持信息、佐证文件、最低要求、作答来源、已确认）。走 SheetJS `writeFile`，**`window.XLSX` 不在时自动降级导出带 BOM 的等价 CSV**（`/assi` 页同样有降级），所以 CDN 挂了不会白屏，只是格式退化。
- **`srvInboxVals()` 收件箱** —— 4 份卷按剩余天数排序，≤14 天描红；只有 `srv-01`（112 题）接了真题库，其余三份点击/导出都给"演示陪衬"toast，**别误以为是 bug**。

## 主线上下文条（2026-07-30 新增）
每个视图容器的**第一个子元素**是一条 34px「主线条」：`圆点(角色色) + 徽章(步号/角色) ｜ ← 上一步 ｜ 这一步 ｜ 交给：跳转按钮`。
- 角色色：客户 `#0B3A82`（底 #F2F6FD）· 可持续 `#002D6B`（#F4F7FC）· 采购 `#0B5B4A`（#F3FAF7）· 供应商 `#5B3FA8`（#F8F6FD）· 事件 `#045B75`（#F2FAFC）。
- 步号：V1 起点 · V2/V4 第1步 · V6 第2步 · V7/V3 第3步 · V10 第4步（回流=第5步）；V5 标「输出层」、V8 标「事件推动·插入」、V9 标「入口闸·供应商第0步」。
- 条随 `[data-view]` 一起切换（写在视图容器内，不是 padwrap 顶层），任一时刻只有一条可见（已实测）。「交给」按钮复用 `go1/go3/go4/go5/go6/go7/go8/go9/go10/goCU`，不新增导航层级。
- v1/v2/v3 是 block 视图 → 条上带 `margin-bottom:14px`；v4–v9 是 flex 列（gap:14px）→ 不加 margin；v10 写在门户内容区 `padding:16px 22px 30px` 的首位。
- 强调值用内联 `<b>` 包裹，未放入 `{{ }}` 洞；双语沿用 `.zh/.en`。

## 顶栏搜索 + V3 筛选排序（2026-07-31，审计 P1-1 / P1-2）
- 顶栏搜索是**真 `<input>`**（`state.q`，`searchVals()` 提供 `q/onQ/clearQ/qDis/qPh/qClearShow`），带清除 ✕。作用于**当前视图主列表**：v3 供应商 / v13 全量要求 / v12 传导对齐 / v11 问卷题目；其余视图 `disabled` + 占位「该视图暂不支持搜索」。
- 各视图的 q 过滤写在各自 vals 里：`v3Vals`（`blob` 字段）· `r13Vals`（`hit13`）· `cas12Vals`（`rowsQ`，筛选 chip 计数随搜索走）· `srvQaVals`（`q11`）。
- **V3 供应商清单**：新增筛选条（分级 A/B/C/D · 类别 AB/SB/SW/其他 · 风险 高/中/低 · 达标区间 ≥80 / 60–79 / <60，chip 样式沿用 v13 的 `opt()`）+ 计数 pill「筛选后 X / 7 家」+ 重置按钮 + 空态行。
- 列表新增**年供货额**列（`biz`），表头 `年供货额 / 绿电 / 绿色评分` 可点排序（`s3k`/`s3d`，箭头 ▼▲⇅），grid 改为 `1.8fr 92px 104px 74px 124px 54px 88px 18px`（表头与行两处必须同步改）。
- 口径诚实处理：主数据 327 家，但 `supplierRaw()` 只有 7 家完整档案 → 计数写「X / 7 家」并在旁注明「主数据共 327 家 · 本演示载入 7 家完整档案」。若要真做到 X/327，需先把 v3 换装到 317 家数据集（仍是待办）。

## 第四轮：③⑦⑧⑨（2026-07-31）
- **③ 总览（v1）**：删掉旧的 300px SVG「主线地图」，换成 **5 格主线流水线**（`mainlineVals()` → `mlStages`）：客户问卷在办 4 份 / 答不了的缺口 7 条 / 并入全量要求 N/7 / 按供应商聚合下发 148 张单 / 回收与回流 470-471+703。每格是入口（点进对应屏并预置状态，如第 4 格自动勾选本轮 9 项要求）；数字随 `casMerged`、`cs12Sent`、`reflow` 实时变。下方「回流」条：未回流时 CTA 是「用导览走一遍」，回流后跳报告中心的回流报告。
- **⑦ 供应商基准清单（v3）**：`supplierRaw()` 现在返回 **327 家**（7 家手写 seed + 320 家由 `supplierSeed()` 之外的确定性哈希生成：名称/品类/城市/分级/绿电/采购额/风险/联系人全部自洽）。列表分页渲染（默认 40 行 + 「显示更多」，`state.v3More`），新增「达标 X/9 + N 项要求在办」列，卡头改名「供应商基准清单」并加「+ 添加供应商」「引入尽调 →」「能力分析 →」三个入口。
- **⑧ 能力达标（v7）改纯分析屏**：删掉 14 行供应商表，换成 **缺口构成分析**（`sdBreak`：按整体达标水平 绿/黄/红、按采购额敞口 ≥$20M/$5-20M/<$5M，各带家数、占比条、采购额）+ 顶部「本项对应要求 REQ #x」说明 + 底部 CTA「在供应商基准清单中查看这 N 家 →」（跳 v3 并预筛 `f3b:'lo'`）。两个主按钮从帮扶主题改为：「导出要求达标分析」「把缺口带入全量要求下发 →」（后者预选要求并跳 v13）。屏顶副标题改为「这一屏只回答一个问题…名单与动作在基准清单」。
- **编号统一**：新增 `supIdent(abcId)` → `{code,name}`（按 ABC 数字取模映射到 327 家基准清单）。已接入：v7 散点标签（显 SUP 编号）、能力档案抽屉标题（真实名（SUP-xxxx），匿名时只显编号）、门户抬头（`personaVals()` → `{{ supPersona }}`）、角色切换器改「供应商视角」。散点图脚注文案也去掉了「帮扶最优先象限」。
- **⑨ 添加供应商**：全屏模态（`addVals()`，`state.addOpen/addF/addRan`）。表单 4 项（企业名 / 统一社会信用代码 / 联系人 / 品类 chip）→「提交并自动跑引入尽调」→ 5 步结果列表（工商制裁 / 品类法规适用 / 问卷自评 / 审核安排 / 准入结论，各带通过或有条件徽章）→ 准入结论卡（有条件准入 · 分级 B− · 达标 7/9 · 2 项待补随下一轮聚合下发）→「加入供应商基准清单 →」。入口两处：v3 卡头、v9 表单区主按钮。
- **已知遗留**：`_supAll` 缓存挂在实例上（热重载后会重算，正常）；`r13Dispatch` 的 148 家为演示定值，不随勾选变化；v7 散点仍来自 `s.sup`（317 条 ABC 数据），与 327 家基准清单是「问卷回收子集 ⊂ 主数据」的关系，口径说明抽屉已解释。

## 第三轮：⑥ 传导对齐改为「先并入 → 按供应商聚合下发」（2026-07-31，已写完代码，尚未点验）
- **v12**：行操作由「下发」改为两段 —— `merge`（并入，写 `state.casMerged[no]`）→ `goDispatch`（跳 v13 并把该批次的要求号写入 `state.r13Sel`）。行 `kind` 增加 `staged`（已并入待下发），筛选 chip 增加「待并入 / 已并入待下发」。底部按钮改「一键并入全量要求（N 项）」：先并入全部未并入项，再次点击才跳 v13 预选。卡头说明改为两步走文案。
- **v13**：行首新增 26px 勾选列（`r.toggleSel/selMark/selBg/selBd`，grid 前缀 `26px`，表头 ✓ = `r13SelAllCas` 选中本轮 9 项）；新增 `r13Dispatch(s,zh,all)` 提供底部聚合操作条（`r13BarShow/r13SelN/r13SupN/r13BarNote/r13Packs/r13PackMore/r13ClearSel/r13Dispatch`）：显示「已选 N 项 · 148 张任务单（一家一张）」+ 前 4 家分组预览；下发时把涉及批次写入 `cs12Sent`（与 v12 回收/回流联动保持不变）、`dispatched=true`、打开 `datareq` 抽屉。
- **未完成**：① 该链路尚未在页面点验（eval 超时，页面 ~11k 节点，验证请拆成多次小 eval）；② 导览第 3 步文案仍写「合并去重、对齐来源、下发供应商」，应改为「合并去重 → 并入全量要求 → 按供应商聚合下发」。
- **后续（用户已确认方向，按序）**：③ 总览驾驶舱重做（不新增页面，升级/合并现有，主线流程 + 今天该做什么）；⑦⑧ 主数据清单升级为 327 家供应商基准清单、能力达标改纯分析屏（去掉「一页管理层摘要 / 导出帮扶优先级清单」等帮扶主题按钮，改为要求传导视角）、ABC56 ↔ SUP 编号统一为「真实名 + SUP 编号，匿名时只显编号」；⑨ 新供应商引入加「+ 添加供应商」表单（企业名/信用代码/品类/联系人 → 自动跑 5 步尽调 → 结论 → 一键加入基准清单）。

## 第二轮审计修复（2026-07-31，用户 11 条中的 1/2/4/5/10/11）
- **顶栏收窄（1）**：搜索框 286→210px 且 `flex-shrink:0`，面包屑加 `white-space:nowrap;flex-shrink:0`；**角色切换器 + 用户头像已从顶栏移到左侧边栏底部**（`roleNowZh/En` 显示当前视角，2×2 chip 网格）。实测 topbar `scrollWidth==clientWidth`、面包屑单行 19px。
- **全屏搜索（2）**：`searchScope()` 一处定义 13 个视图的占位文案 + 要过滤的数组键；`applyQ(R,s)` 在 `renderVals()` 末尾对 `R` 里对应数组做通用 blob 过滤（跳过 `#`/含 `:`/含 `px` 的样式值），因此 renderVals 现在写成 `const R = {...}; this.applyQ(R,s); return R;`。v3/v11/v12/v13 仍用各自 vals 内的专用过滤（不在 applyQ 列表里）。
- **客户名统一（4）**：`custDefs()/custKeyOf(raw)/cn(key)` —— 问卷线的 P/M/T/V 映射到矩阵同一批真实客户：P=Chery 奇瑞(OEM-01)、M=Geely 吉利(OEM-03)、T=GWM 长城(OEM-04)、V=NIO 蔚来(OEM-02)。`cn()` 自己读 `this.state` 的 anon/lang。已替换：收件箱行、卷头/原件/在手卷标题（改为 `srvOpenTitle/srvRawTitle/srvOpenCust` 洞）、导入向导客户 chip、v12 来源徽章与 mock 徽章、回流横幅（`rfScoreLabel/rfUnionNote`）、门户提交提示、批量下发 srcs、回收抽屉时间轴。
- **进问卷必回收件箱（5）**：`go11` 与 tabbar 的 v11 跳转都带 `srvOpen:'',srvImport:0`。
- **匿名口径（10）**：供应商的 `.na` 由「英文名」改为 **SUP 编号**（`nameNa:r.code`，抽屉同改），行内二级信息在匿名态隐去重复编号（`codeShow`）。客户名匿名走 `cn()`。**注意：V7/V10 的 ABC 编号体系尚未与 SUP 统一**（下一轮随「供应商基准清单」一起做）。
- **供应商端问卷正文（11）**：新增 `supQDefs()`（9 题：目标/净零/SBTi/排放量/上游传导/绿电路线/绿电占比/LCA/PCF，每题带 `req` 映射与 AI 提示）+ `supQVals()`。UI 是 `display:{{ supQShow }}` 的**全屏固定层**（深绿 #0E3B3A 顶条 + 9 张题卡），控件只有两种：chip 单选（`q.opts`）与数值输入（`q.numShow/onNum`）；证据上传占位 `q.upload` 写 `state.supEv`；答案写 `state.supA`（AI 预填来自 ABC56 的 9 位 f 串，未达标项留空并标「待你填报」）。顶条动作：导出 Excel 模板 / 导入填好的 Excel（会一次性填满 9 题并提示 1 处单位纠正）/ 保存草稿 / 提交（未填满时按钮显示「还有 N 题未填」；填满后提交 → `supSubmitted+reflow` 并触发回流故事）。入口三处：门户 hero 的「打开年度气候问卷（9 题）」、门户任务卡 CTA（`t.ctaGo`，REQ-01 打开正文、其余给说明 toast）、Autoliv 侧 REQ-01 详情抽屉的「查看该问卷正文（供应商视角）」。
- **下一轮待办（用户已确认方向）**：③ 总览驾驶舱重做（不新增页面，升级/合并现有）；⑥ v12 改为「先并入全量要求 → 在全量要求页按供应商聚合统一下发（一家一张单）」；⑦⑧ 主数据清单升级为 327 家供应商基准清单、能力达标改纯分析屏（去掉帮扶主题按钮，改为要求传导视角）、ABC56↔SUP 编号统一；⑨ 新供应商引入加「+ 添加供应商」表单 → 自动跑 5 步 → 一键入基准清单。

## 审计修复 P1-3 → P2-8（2026-07-31）
- **P1-3 口径说明**：顶栏 `ⓘ 口径说明` → 新抽屉 kind `gloss`（`.dwd.gl`，`glossVals()`）。三组勾稽链：供应商 327→317→148（去重）· 客户 14→6→4 · 要求 47→37/112/8，每个数注明范围与"在哪屏用"。KPI ⓘ 用新 CSS 类 `.itip`+`.tp`（hover 出提示，与 `.scoretip` 并存）：V1 `kpiData()` 按标签查 `tips` 表、V7 `sdKpis`、V13 `r13Kpis` 逐条加 `tipShow/tipZh/tipEn`（**没有提示的行必须显式写 `tipShow:'none'`**，否则空洞会让 `.itip` 的类默认 display 生效、冒出空气泡）。
- **P1-4 跨屏贯通**：`supCasNos(code)` 为 7 家 mock 供应商映射「收到的下发条数 + 达标 X/9」（演示映射）。supplier 抽屉抬头加 分级/年供货额/达标/风险 四枚 chip；底部两跳转 `dws.toPortal`（→v10 + toast 说明 demo 统一 ABC56）与 `dws.toCascade`（→v12 且 `focusSup=code`）。abc 抽屉同样加 `dwabToPortal / dwabToCas`。v12 行按 `focusSup` 或 `casHi` 高亮（`hiBg/hiBar/hiShow/hiLabel`）+ 顶部高亮横幅 `cs12FocusShow/Label` 与「清除高亮」。
- **P1-5 导览**：`tourSteps()` 5 步（v11 导入 → v11 作答/得分 → v12 → v10 → v1+reflow），`tourVals()` 提供顶栏按钮态与底部固定说明条（`state.tour` 0=关）。每步用 `setState({...step.set, tour:i})` 一次切视图+子状态。
- **P2-6 报告中心**：新 `state.repType`（survey/cascade/full/reflow），向导从 3 步变 4 步（第 1 步选类型）。`reportVals()` 内 `T{}` 按类型给标题/徽章/3 个指标/目录/导出章节，数字取自 `s.srv`(v11)、`s.cs12Sent`+reflow(v12)、`s.reqs`(v13)；预览抬头加「数字来源」条 `repSrcZh/En`。
- **P2-7 v11 卷头折叠**：原件横幅 / 客户历史 / 解析复核 / 工厂档案 / 校验 四块包进 `display:{{ srvHeadShow }}` 容器，上方一条摘要栏（客户P · 112 题 · AI 83 · 校验待补 2）`srvHeadToggle`，默认收起 → 进焦点态直接看 tab。
- **P2-8 一致性**：① 新增 `casBatches()` 单一定义（7 批 → 9 项要求），`casReqNos()` 由它派生，v13「传导中」徽章显示批次号并跳 v12 高亮该批（`casHi`），v13 KPI 改为「9 项 · 7 批」；② v4/v5/v6 主线条本来就有（已核）；③ v13 行改为可点开新抽屉 kind `req13`（`.dwd.r3` + `r13Detail()`：周期/系统/覆盖/帮扶 + 来源去向链 + 两个跳转）；报告库行可点（toast）+ 「查看全部」改真按钮；补齐 8 个死按钮（导出简报/生成客户报告→v5/PDF/XLSX/发送/一键承接/AI 三问）。

## 侧边栏 / IA（2026-07-30 重构，一级 10 → 5）
根元素新增 `data-dom`（ov/cust/sup/reg/rep/portal），**侧边栏高亮按 dom，页面切换按 view**；域内切换用内容区顶部 tab 条（`.tabbar`，由 `shellVals()` 的 `tabs/hasTabs/domNote*` 驱动）。
- 工作台：**总览驾驶舱**（v1）· **客户要求**（v2 要求矩阵 / v4 合规雷达 / v11 客户问卷待建 / v12 传导对齐待建）· **供应商**（v3 主数据 / v7 能力达标 / v9 新供应商引入）· **法规与管制合规**（v6 义务图谱 / v8 实时监控墙）；输出：**报告中心**（v5）。
- 顶栏新增**角色切换器**（可持续/采购/供应商 ABC56/客户）；角色仍由 view 派生、**无新增 state**：`roleOwn={v1,v2,v4,v5,v6→sus; v3,v7,v8,v9→proc; v10→sup}`，未命中回落 sus。点 chip = `setState({view: home})` + toast（可持续→v1 / 采购→v7 / 供应商→v10 / 客户→v2 并弹"完整客户问卷线第 4 步上线"提示，不再是死 toast）。
- 根元素 `data-role` 驱动**侧边栏只亮当前线**：`[data-role="proc"]` 淡化 nOV/nCU/nRP，`[data-role="sus"]` 淡化 nSU（仅 opacity .4 + grayscale，hover 回亮）；停在总览 v1 时 `[data-view="v1"] .nav-i` 强制全亮。法规域 nRG 两条线都亮（v6 属可持续、v8 属采购）。
- 供应商门户 = 供应商角色首页（已从侧边栏移除）。
- 排查提示：切换后立刻用 `getComputedStyle` 读 opacity 会拿到**上一状态的陈旧值**，验证前先强制 reflow（`void document.body.offsetHeight`）再读。
- 旧导航类名 `n1–n10` 已废弃（改为 nOV/nCU/nSU/nRG/nRP）；`go1/go5/go7…` 等跳转函数全部保留，跨屏链不受影响。
- **V4 删除了与 V2 重复的 8×6 热力图**，换为「按客户看满足率」（`oemScores`，满足率=(覆盖+0.5×进行)/已提要求，行可点→该客户聚焦视图）——新信息而非重复。`heatRows/heatOems/heatCols` 仍在 `radarData()` 里保留未用。

## 第一批 V1–V6（历史记录；当前已是 14 视图 + 11 抽屉）
双语中/EN + 真实名↔匿名 OEM-01… 全局开关。以下是这六屏最初的形态，后续各轮的改动见上方分轮小节。
- **Shell**：侧边栏（品牌 / 工作台导航 5 项 / 自身合规导航 1 项 / 客户范围 OEM 列表 / 底部审核卡）+ 顶栏。
- **V1 总览**：Hub banner + 5 KPI + 双向传导图 + 减排进度 + 待办队列。选中 OEM 切「客户要求明细 + 档案 + 缺口整改」聚焦视图（`.only-all/.only-focus`）。聚焦视图「查看整改路径」按钮 → 要求抽屉。
- **V2 矩阵**：**8 指标（E×4·S×3·G×1）× 6 OEM**（吉利/长城/长安/小米/蔚来/奇瑞）承诺/请求/缺口热力矩阵，行可展开显示真实条款/出处/当前vs目标/负责人/证据/关联供应商。数据源自 `uploads/matrix_cells_副本.csv` + `matrix_detail_副本.csv`（已回填）。
- **V3 供应商**：五步流程 + 范围三饼图 + A–D 分级柱 + 供应商清单（含**真实组织名 + 头像 + 绿色评分进度条 + 评分构成 tooltip**）。行可点开供应商档案抽屉。
- **V4 合规雷达**：**8 metric_code × 6 OEM 热力图（E/S/G 色标，点格→要求抽屉）** + 「客户要求全景」卡（SAQ 5.0 人权12项 + RSCI 11模块）+ E/S/G 雷达 + 缺口预警列表（行可点）。
- **V5 报告导出**：客户报告生成向导（选客户/框架/区间→预览）+ 模板库（CDP/SBTi/客户模板）+ 历史报告库。
- **V6 法规合规图谱**（Autoliv 自身合规，`nav .n6`）：AI 扫描 CBAM/ISO14067/LkSG/EUDR/CSDDD/SBTi/RSCI，按强/中/已排除分级 + 「为何适用」+ AI 顾问侧栏。行可点→法规义务抽屉。

## 供应链·采购侧（M2/M3 第一批，2026-07-30）
侧边栏第三组「供应链 · 采购侧」（`.n7/.n8`，活动色 `#0B5B4A` 绿，与客户线海军蓝区分视角）。
- **V7 供应链能力指挥舱**（M2）：5 KPI（317 家/$776M・绿 107・红 110・未传导 67・Top20×低能力 11）+ 9 题达标率双口径柱（家数/采购额加权，可点选）+ 采购额×能力四象限散点（317 气泡，红 = Top20×≤6 项的 11 家并标名）+ 差距下钻（选中题的未达标 Top14，行可点）+ 帮扶服务映射 5 卡 + AI 数据质量卡（ABC219 将 kWh 填为 % 被拦截）+ 全链绿电分布（对照要求 #17）。
- **V8 供应链合规监控墙**（M3）：三栏——政策流（MOFCOM 2026-06-29 公告卡，AI 抽取徐章 + 20 家实体分组，下接 BIS/EU/海关 3 条际衬）／碰撞图谱（名单实体 4 盒 ↔ 主数据 3 节点，3 条贝塞尔连线按选中加粗，行/节点可点选）／告警处置（受影响链路/AI 判定/建议处置 + 三按钮、处置留痕时间轴、黑卡现场讲解口径）。每条链路带「虚构演示」角标。
- **abc 抽屉**（新增第 5 类）：供应商能力档案——ABC 编号/分层徐章/采购额+排名/绿电比例 + 9 项逐项 ✓✕（带 REQ 编号与对应帮扶服务）+ AI 帮扶建议（按是否落入优先象限变文）+ 下发方案/发起数据请求/供应商视角。
- **V9 新供应商引入尽调**（M4，`nav .n9`）：企业名/信用代码输入条 + 5 步时间轴（通过/黄旗/进行中/待完成四色态，带耗时与结论）+ 效率对比条（2–3 周 vs 6 分钟）+ 准入结论卡（黄·有条件准入）+ 10 项红线清单（参照主机厂准入实践 + 要求 #22–#29）+ 引入后自动衔接（→ V7/V10/V8）。案例全虚构并标注。
- **V10 供应商门户**（M1，`nav .n10`，侧边栏「视角切换」组）：**独立外观**——CSS 将 aside + .topbar 隐去（`display:none !important`，内联样式必须用 important 才能盖）、根网格换单列，门户自带 #0E3B3A 深绿顶栏（标签页 + 「切回 Autoliv 采购侧」）。内容：你的 37 项 hero（四统计 + 完成度条 + 最近截止倒计）+ 分类筛选（默认「需你行动」5 项，避免 37 项长滚动；列表按 due/gap/todo/later/done 排序）+ 任务卡（三色 type 徐章 + aiCard 人话 + 交到哪个系统 + 点开看 definedZh/生效年份/平台服务 + 两按钮）+ 右栏 AI 助手/术语卡/你的缺口。persona = ABC56（amber），9 题映射到 REQ #7/6/5/8/34/19/16/2/3，其余标「待自评（演示）」。
- 数据：`data/supply_suppliers.json`（317 家精简集，`componentDidMount` fetch，字段 n/s/p/t/f（9 位 0-1 串）/r/a）；聚合数字与 9 题统计内联在 `sdQStats()`，首屏不等 fetch。原包 `data/supply_demo.json`、`data/survey_demo.json` 已就位（M1/M4/V7 问卷线未建）。

## 抽屉（右侧滑出，**11 类**，统一任务模型）
`.dw-wrap[data-kind="…"]` 驱动显隐。当前全集（`state.drawer` 取值 ↔ 内容容器类名）：

| kind | 类名 | 内容 | 加入 |
|---|---|---|---|
| `supplier` | `.dwd.s` | 供应商档案 | 首批 |
| `requirement` | `.dwd.r` | 客户要求详情 | 首批 |
| `action` | `.dwd.a` | 待办 | 首批 |
| `reg` | `.dwd.rg` | 法规义务 | 首批 |
| `datareq` | `.dwd.dr` | 数据请求单 | 首批 |
| `abc` | `.dwd.ab` | 供应商能力档案（ABC 编号体系） | M2/M3 |
| `gloss` | `.dwd.gl` | 口径说明（三组勾稽链） | P1-3 |
| `req13` | `.dwd.r3` | 全量要求行详情 | P2-8 |
| `cascade` | `.dwd.cs` | 传导批次 | 第三轮 |
| `srvimp` | `.dwd.si` | 问卷导入 | 第五轮 |
| `cand` | `.dwd.cd` | 引入中候选企业（5 步尽调） | 第六轮 |

新增一类要同时改三处：`state.drawer` 取值、helmet 里的 `.dw-wrap[data-kind="x"]` 选择器、`drawerVals()` 分派。

- **supplier**：评分拆解 + 关键事实 + 关联客户要求 + 近期动态 + 「发起数据请求」按钮 → datareq 抽屉。
- **requirement**：原始条款 + 当前/目标 + 负责人/截止/证据 + 整改路径 steps + 关联供应商。有专属 `reqDetail()`，其余由 `reqFromMatrix()` 合成。
- **action**：待办描述 + 处理清单 + 活动记录。
- **reg**：法规摘要 + 触发周期 + 为什么适用 + AI 推荐动作。
- **datareq**：完整《供应商 ESG 数据请求单》（抬头/编号/周期/截止 + 7 项指标清单含编码/证据/格式/强制标记 + 提交回执说明）。

## 关键实现注意（务必遵守）
1. **禁止在 `{{ }}` 模板洞里放 HTML 标签**（会被转义成字面 `<b>`）— 强调值用模板内 `<b style>` 元素包裹。改 `<b>` 时只动 JS 字符串，别用脚本全局删标签（曾误伤模板加粗）。
2. **大段 dc_write 易超时中断** → 分小块 `dc_html_str_replace` / `dc_js_str_replace` 增量构建。
3. **视图/OEM/抽屉切换靠根元素 `data-view/data-oem` + `.dw-wrap[data-kind]` + helmet 属性选择器 CSS**，非 JS 显隐。
4. **抽屉显隐用 `.dw-wrap` 自身属性**，不能用 `[data-drawer="x"] .dw-wrap` 后代选择器 — 运行时把 fixed 定位层提出了根节点，后代选择器匹配不到（已踩坑修复）。
5. **`str_replace_edit` / `dc_*` 的 old_string 里不能含 `</x-dc>`**（会被拒）；插入到 `</main>` / `</div>` 锚点前。
6. state 关键字段：
   - 全局：`view, oem, lang, anon, drawer, dwKey, toast, tour`
   - 矩阵/报告：`matrixOpen, expandAll, repOem/repFw/repPeriod, repType`
   - 供应商：`sup, sdQ, m3sel, sd37, v3Seg, v3More, cands, addOpen/addF/addRan`
   - 法规 v6/v8：`regPack, regCat, regDim, regSt, regStar, regNew, regOpen, regExOpen, polSrc, ecScen`
   - 单项要求 v14：`r14No, r14Fil, r14Sel`
   - 客户问卷 v11：`srvOpen, srvImport, srvTab, srvLocked, srvSkipped, srvChkFil, srvQOK/srvQTxt/srvQEd/srvQOr, srvA/srvS/srvF/srvOK/srvNA, srvFilter, srvSubmitted`
   - 传导/要求：`casMerged, cs12Sent, casHi, focusSup, r13Sel, reqs, reflow`
7. **新视图必须插入到 `<div class="padwrap" style="padding:16px 22px 30px…">` 容器内**（与 v1–v6 同级）。写在该容器之外、`</main>` 之前，运行时会把它提到根节点外（与 dw-wrap 同一踩坑），`[data-view]` 祖先选择器失效 → 永远 display:none。
8. **SVG `<text>` 的文本不能用 `{{ }}` 洞**（属性洞可以）——运行时会包成 `<span class="sc-interp">`，SVG 不渲染 HTML 子节点，标签隐形。动态文字标签改用给 svg 套 `position:relative` 容器 + 绝对定位 HTML 层（百分比坐标，svg 需 `height:auto` 保证等比缩放）。V7 散点点名已按此实现（带同 y 防压字错位）。
9. **内联 `display:flex` 的元素要隐去必须 `display:none !important`**（V10 隐 aside/topbar 踩过）。
10. **凡是缓存派生结果，缓存键必须带上依赖数据的规模**。`state.reqs` / `state.srv` / `state.sup` 都是 `componentDidMount` 里异步 fetch 的，首帧一定是空的；按 id 单独缓存会把首帧算出来的 0 值永久钉住。现成写法见 `supCompliance()` 的 `code+':'+reqs.length`，并且**数据没到时直接返回空壳、不写缓存**。
11. **同一个数字只能有一个来源函数**。已经统一的：供应商达标 → `supCompliance()`（v3 行/供应商抽屉/候选抽屉三处共用）；单项要求达标 → `reqCompliance()`（与 v7 达标全景同源）；回收覆盖 → `reqCov()`；要求号解析 → `reqNosOf()`；已测量映射 → `measMap()`；客户名 → `cn()/custKeyOf()`；传导批次 → `casBatches()`；要求分类 → `reqCats()`。新增派生数字前先找有没有现成的，别在 vals 里就地再算一遍。
12. ~~回收覆盖数公式在两处~~ **第七轮已收敛成 `reqCov(x)` 单一定义**（5 处调用）。要改覆盖口径只动这一个函数。注意它有个前置分支：命中 `measMap()` 的要求直接返回 317，走的是 V7 那批问卷回收的同源数字，不套公式。
13. 逻辑 helper：`matrixData() / matrixDetail() / radarData() / supplierRaw() / supplierData() / drawerVals() / reqDetail() / reqFromMatrix() / actionDetail() / regVals() / regDetail() / dataReqFor() / reportVals() / focusProfile() / reqCats() / supCompliance() / casBatches() / custDefs() / cn()`。

## 数据源（uploads/ 与 data/）
四个 JSON 都在 `componentDidMount` 里 fetch，**首帧一定拿不到**（见「关键实现注意」第 10 条）：

- `data/reg_demo.json` → `state.regPack`（第七轮新增：16 条法规 / 7 个业务节点 / 合规日历 / 出口管制）。驱动 v6 法规图谱与 reg 抽屉；**没到时 v6 列表为空**，抽屉会回落到硬编码的 `regDetail()`。

- `data/supply_demo.json` → `state.reqs` 等（D0′ 包：37 项要求 / 317 家 / 聚合 / MOFCOM / 尽调）。**37 项要求是 `supCompliance()` 与 v13 的底座**，没到之前评分全是 0。
- `data/survey_demo.json` → `state.srv`（D0 包：112 题客户问卷 + `inbox` + `factoryProfile`）。**第五轮起已全面接入 v11**（收件箱 / 校卷 / 作答 / 交卷 / 导出都读它），不再是"未接入"。
- `data/supply_suppliers.json` → `state.sup`（317 家精简集，字段 `n/s/p/t/f/r/a`，`f` 是 9 位 0/1 串 = 一个供应商的 9 题达标）。供 V7 散点 / 下钻 / abc 抽屉用；聚合数字与 9 题统计内联在 `sdQStats()`，首屏不等 fetch。
- `matrix_cells_副本.csv` / `matrix_detail_副本.csv`（8 指标×6 OEM，已回填 V2/V4，代码里是内联值，运行时不读 CSV）
- `OEM可持续供应链要求_调研详情.md`、`OEM_S维度要求专题_人权劳工与负责任采购.md`（条款出处底稿）

注意 317（问卷回收子集）↔ 327（供应商基准/主数据）↔ 引入中候选（不计入任何分母）三个口径的关系，`gloss` 抽屉里有完整勾稽链。

## 跨屏联动（新屏不是孤岛 —— 从旧屏进入）
新模块除侧边栏入口外，均在现有屏的卡头（`.chd`）右侧挂了文字链跳转，不新增导航层级：
- V1 双向传导图 →「下游 317 家能力详情」→ V7；
- V3 供应商分级分布 →「按问卷能力看」→ V7；V3 供应商清单 →「+ 新供应商引入尽调」→ V9；
- V4 合规缺口预警 →「出口管制与名单监控」→ V8（同时补回了该卡丢失的 `.chd` 标题）；
- V7 差距下钻 →「在供应商主数据中打开」→ V3；abc 抽屉 →「供应商视角」→ V10；
- V8 碰撞图谱 →「在合规雷达中查看」→ V4；V9 衔接卡 → V10。

## 布局约束（勿自由发挥）
- 所有视图均在 `.padwrap`（`padding:16px 22px 30px`）内，左右边路 **22px**、顶部 **16px**，卡间距 `gap:14px`；新增屏不得自定义边路。
- V10 虽然隐了 aside/topbar，内部仍用 `0 22px` / `16px 22px 30px`，与其余屏对齐（已实测 22/22）。
- 卡头统一用 `.chd` + `h3` + `.pill`，右侧说明文字 `margin-left:auto`；跨屏链接用 11px/700 文字按钮，不用实心按钮。

## 待办 / 下一步
- 已用 **mock 数据补全**：`supplierRaw()` 每家新增 `biz/riskK/site/contact`（年供货额/风险等级/生产基地/对接人），供应商档案抽屉 6 张 fact + 数据请求单抬头(对接人/基地)均取真值；anon 模式下基地/对接人隐去为「—」。
- 已用 **toast 补全交互**：`showToast(zh,en)` + state.toast；抽屉所有静态按钮（整改计划 / 标记完成·指派 / 生成整改任务·订阅触发流 / 发送请求单·PDF·存草稿）均 onClick 弹出确认 toast（2.8s 自动消失，底部居中）。如需真实动作再接后端。
- **仍需用户提供以贴近真实**：Autoliv 实际发给供应商的数据清单字段/填报周期/可接受证据类型（现为 7 项 mock）；矩阵 Autoliv 侧真实当前值（CMRT 覆盖率、SAQ 等级等，现为演示占位）。

### 旧待办的当前状态（2026-08-02 复核）
- ✅ **v11 客户问卷**：已建，且从"三步合在一个 tab"演进成 `srvTab` 三段式（校卷/作答/交卷），见第五轮。
- ✅ **v12 传导对齐**：已建，并在第三轮改成「先并入全量要求 → 按供应商聚合下发」。
- ✅ **V3 换装**：已从 7 家扩到 327 家主数据清单，并在第六轮加了「引入中」分段。
- ⬜ **datareq 抬头 `sourceSurveyQ`**：仍未做。
- ⬜ **V2 三处来源徽章**：仍未做。
- ⬜ **供应商抽屉合并为 4 tab**（档案/碳数据/问卷能力/关联客户要求）：仍未做；第六轮只是给它接了 `supCompliance()`，结构没动。
- ✅ **总览驾驶舱随新增内容更新**：第八轮整屏重做（`v1Vals`），价值链合规达成度 + 三条紧急事项 + 两个需求来源 + 五段主线 + 管理 KPI 卡。第四轮的 5 格主线流水线已被取代（残留死代码见第八轮小节）。

### 已知遗留（不是 bug，别去"修"）
- **v14 不在顶栏搜索范围内**：`searchScope()` 仍只定义了 v1–v13 的占位与过滤键，v14 会落到「该视图暂不支持搜索」的 disabled 分支。名单筛选用屏内的 `r14Fil` 即可；要接搜索得往 `searchScope()` 加一条。
- **`regDetail()` 是活代码，别当死表删**：法规内容虽已外置到 `reg_demo.json`，但它仍是 reg 抽屉的兜底，且 `reqOrigin()` 靠它反查法规 ↔ 要求关联。
- `r13Dispatch` 的 148 家为演示定值，不随勾选变化。
- v7 散点仍来自 `s.sup`（317 条 ABC 数据），与 327 家主数据是「问卷回收子集 ⊂ 主数据」的关系，`gloss` 抽屉已解释。
- v11 收件箱 4 份卷里只有 `srv-01` 接了真题库，其余三份点击/导出均给"演示陪衬"toast。
- `_supAll` / `_compCache` 挂在实例上，热重载后会重算，正常。
- 第三轮的 v12→v13 链路当时未点验（eval 超时，页面节点多）；如需验证请拆成多次小 eval，别一次跑全量。

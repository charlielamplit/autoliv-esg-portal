# Handoff — Autoliv ESG Cockpit

供应链 ESG 合规工作台，服务外方管理层。单文件 DC：`Autoliv ESG Cockpit.dc.html`（模板 + 逻辑类 `Component`，~1300 行）。

## 设计基准
- 参考 ComplianceCenter（`/projects/5aede5ad-08ed-4ae4-98c2-2dcf61dbd7ed/docs/redesign/mockups/customer-demos/sdhi/07-compliance-center.html`）：224px 左侧边栏 + 顶栏面包屑 + 卡片语言 + water/leaf/earth/ink token。
- Autoliv 海军蓝 `#002D6B` 作品牌层。绿=达标、橙=进行、红=缺口。
- 字体：Plus Jakarta Sans / Manrope(数字) / Noto Sans SC / JetBrains Mono(编码)。
- **全内联样式**；helmet `<style>` 仅放 reset + 属性选择器开关（view/oem/lang/anon/drawer 切换）。

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

## 已完成（6 视图 + 4 抽屉，双语中/EN + 真实名↔匿名 OEM-01… 全局开关）
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

## 抽屉（右侧滑出，4 类，统一任务模型）
`.dw-wrap[data-kind="…"]` 驱动显隐（kind ∈ supplier/requirement/action/reg/datareq/abc）。
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
6. state 关键字段：`view, oem, lang, anon, matrixOpen, expandAll, repOem/repFw/repPeriod, drawer, dwKey, toast, sup, sdQ, m3sel`。
7. **新视图必须插入到 `<div class="padwrap" style="padding:16px 22px 30px…">` 容器内**（与 v1–v6 同级）。写在该容器之外、`</main>` 之前，运行时会把它提到根节点外（与 dw-wrap 同一踩坑），`[data-view]` 祖先选择器失效 → 永远 display:none。
8. **SVG `<text>` 的文本不能用 `{{ }}` 洞**（属性洞可以）——运行时会包成 `<span class="sc-interp">`，SVG 不渲染 HTML 子节点，标签隐形。动态文字标签改用给 svg 套 `position:relative` 容器 + 绝对定位 HTML 层（百分比坐标，svg 需 `height:auto` 保证等比缩放）。V7 散点点名已按此实现（带同 y 防压字错位）。
9. **内联 `display:flex` 的元素要隐去必须 `display:none !important`**（V10 隐 aside/topbar 踩过）。
7. 逻辑 helper：`matrixData() / matrixDetail() / radarData() / supplierRaw() / supplierData() / drawerVals() / reqDetail() / reqFromMatrix() / actionDetail() / regVals() / regDetail() / dataReqFor() / reportVals() / focusProfile()`。

## 数据源（uploads/ 与 data/）
- `data/supply_demo.json`（D0′ 包：37 项要求 / 317 家 / 聚合 / MOFCOM / 尽调）、`data/survey_demo.json`（D0 包：112 题客户问卷）——后者尚未接入 UI。
- `data/supply_suppliers.json`（由 supply_demo 衍生的精简集，供 V7 散点/下钻/抽屉用；
- `matrix_cells_副本.csv` / `matrix_detail_副本.csv`（8 指标×6 OEM，已回填 V2/V4）
- `OEM可持续供应链要求_调研详情.md`、`OEM_S维度要求专题_人权劳工与负责任采购.md`（条款出处底稿）

一个供应商 = 一行 9 位 0/1 串）。

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
- **未建（已确认的下一批）**：v11 客户问卷（7a/7b/7c 三步合在一个 tab 内）、v12 传导对齐（三列：客户条款 ↔ Autoliv 目标/37 项 ↔ 发给供应商的 10 题）、datareq 抬头 `sourceSurveyQ`、V2 三处来源徽章、V3 换装 317 家、**供应商抽屉合并为 4 tab**（档案/碳数据/问卷能力/关联客户要求）、**总览驾驶舱根据新增内容更新（最后做）**。

# D0' 交付说明 · `supply_demo.json` 数据包（供应链部门四模块 · 给 Claude Design 的注入指南）

**生成**：2026-07-30，Cowork 侧 AI 真跑·结果固化。零泄漏断言通过（无 Polestar/极星字样；供应商恒定匿名 ABC1-317；M3 链路与 M4 案例全部虚构并带 `fictional:true` 标记）。
**来源**：附件1 PDF 37 项全量提取（含 p12-22 Defined-as 细节）+ 附件2 xlsx 317 家 + MOFCOM 2026-06-29 公告（公开信息）。

## 一、关键数字（真算）

| 指标 | 值 |
|---|---|
| 要求任务包 | **37 项 = 硬要求 18 + 新要求 2（#3 PCF、#21 零毁林）+ 期望 17**；2025 年（含）前生效的强制项 19 |
| 供应商 | 317 家 / $776M；**绿 107（9/9 全达标，38% 采购额）· 黄 100（6-8 项）· 红 110（≤5 项）** |
| 帮扶最优先象限 | 采购额 Top20 × 达标≤6 项 = **11 家**（ABC2/3/4/6/7/9/11/12/15/17/18） |
| 最弱三项能力 | LCA 54% · PCF 62% · 净零路线图 65% —— 恰好对应 2025 年新硬要求 #3 PCF，帮扶叙事完美 |
| 未传导（#34 缺口） | 67 家（13% 采购额） |
| 数据质量 | ABC219 绿电填 910,808（kWh 当 %）→ AI 校验拦截演示点 |

注：v2 需求稿中"47 家高风险"为 ≤2 项达标的极端口径；本包分层口径为红=≤5 项（110 家）。UI 建议用红黄绿三层 + 极端组注记。

## 二、JSON 结构

```
meta            — 统计汇总（上表）+ 来源 + 免责
requirements[37]— no/category(5类)/type(req|exp|new)/year/title/titleZh/
                  definedZh(条款要点)/system(载体)/frequency/service(我方帮扶)/
                  aiCard(给供应商的"人话"解释 → M1 任务卡正文)
suppliers[317]  — id/name/spend/q1-q10(bool)/rePct/reAnomaly/passCount/tier
aggregates      — questionStats[9](达标率双口径+linkedReqs+缺口家数/金额+对应服务)/
                  segments(green/amber/risk/top20LowCapability/notCascaded)/
                  renewable(中位23/均值28/为零67家/≥30档147家)/dataQuality
mofcom          — policyCard(AI抽取的公告卡)/collisions[3](核查/关注/提示三级,fictional)/pitch/disclaimer
duediligence    — 虚构案例：5步筛查(带耗时与结论)/黄旗有条件准入/“2-3周→6分钟初筛”对比
```

## 三、注入映射（模块 ← 字段）

- **M2 能力指挥舱**（第一优先）：KPI ← `meta.stats`；能力柱状 ← `aggregates.questionStats`（双口径）；四象限散点 ← `suppliers[]`(x=spend, y=passCount, 高亮 top20LowCapability)；差距下钻 ← 按 q 过滤 suppliers；**帮扶映射 ← questionStats[].service + gapN/gapSpend**（"LCA 缺口 145 家/$xxM → 进阶培训⑥"式卡片）；数据质量卡 ← `aggregates.dataQuality`；
- **M3 监控墙**（并列第一）：政策卡 ← `mofcom.policyCard`（标 AI 抽取徽章）；图谱三链路 ← `collisions[]`（level 三色，`fictional` 必须渲染"虚构演示"角标）；右栏话术 ← `pitch`；
- **M4 尽调流** ← `duediligence`（步骤时间轴 + 黄旗结论 + 对比条"2-3周 vs 6分钟"）；
- **M1 任务包**：37 项列表 ← `requirements[]`（type 三色徽章：硬要求/新要求/期望 + year 倒计时；卡片正文 = `aiCard`；点开 = definedZh + system + service）；供应商个人视图可用任一 amber 供应商（如 ABC56）persona：其 q1-q10 映射到对应 requirement 的达标状态，其余条款标"待自评（演示）"；
- **与既有 Cockpit 联动**：V3 供应商清单可直接换装本包 suppliers[]（317 家真实分布替换原 mock）；datareq 抽屉的批量下发对象 ← segments.notCascaded / questionStats 缺口清单。

## 四、红线与注意

1. 供应商恒定匿名（ABC 编号），无还原开关；M3 名单实体（三菱电机等）为公开公告信息可显示真名，但 **collisions 链路与 M4 案例必须带"虚构演示"标注**（字段已给）；
2. `requirements[].aiCard` 是面向供应商的口语化文案，M1 直接用，勿再改写回官样文章——通俗正是卖点；
3. #36 的工具链接指向 SupplierAssurance(NQC)——讲解时可点出"Autoliv 自评体系用的就是 SAQ，我们对题库了如指掌"（呼应 S 维度专题研究）；
4. 文件 ~108KB，与 survey_demo.json 同法注入（uploads 数据文件，勿整段贴模板）。

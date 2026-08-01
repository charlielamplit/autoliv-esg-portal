# D0 交付说明 · `survey_demo.json` 数据包（给 Claude Design 的注入指南）

**生成**：2026-07-30，Cowork 侧 AI 真跑·结果固化（口径见 V7 讨论稿 §10）
**来源**：Customer Survey Demo.xlsx（客户P SSI，NDA 测试数据）；已完成匿名清洗并通过零泄漏断言检查（Polestar/Volvo/联系人姓名邮箱在全文件零出现，恒定匿名，与 anon 开关无关）

## 一、关键数字（全部真算，非拍脑袋——替换讨论稿 §6 演示脚本中的占位值）

| 指标 | 值 | 说明 |
|---|---|---|
| 题量 | 112（是81 / 否26 / 不适用5） | 5 支柱 |
| **AI 自动匹配** | **83/112（74%）** | 平台数据直出36 + 证据库引用27 + 历史答卷复用20；29 题需人工（叙述类） |
| 差距（失分题） | 26 | 全部带整改建议 + quick/mid/long 分层 |
| 空心"是"（缺支持信息） | 2（Q8 等） | 对应校验条"未填支持信息" |
| 红线（最低要求）题 | 17 道，触碰 0 | Q2/3/4/11/12/62/80/82-88/91/97/100，全部答"是" |
| **得分三档** | **74.2 → 86.4 → 97.0** | 当前 → 快速整改（quick）→ 完成全部行动计划（quick+mid） |
| 传导动作 | 12 | datareq×5 · cmrt×2 · audit×2 · training×1 · target×1 · standard×1 |

分支柱三档：气候中和 66.7→78.8→97.0 ｜ 循环性 63.6→81.8→90.9 ｜ 透明度 69.2→84.6→100 ｜ 包容性 95.2→100→100 ｜ 环境管理体系 88.2→94.1→94.1

**演示叙事更新**：五幕动线第二幕口径改为"AI 已自动匹配 83/112"；第三幕得分改为"74 → 87 → 97 三档"；第四幕主角仍是 Q8（答"是"但缺支持信息 → 现场生成数据请求单），备选切换 Q64/65/67（矿产组，领导在场时用）。

## 二、JSON 结构

```
meta            — 问卷元信息 + stats（上表全部数字）+ scoringNote（算分口径披露）
factoryProfile  — 工厂档案（7b 顶部/General Info 面板用：1309人/650万kWh/绿电0…）
pillars[5]      — key/name/nameEn/nQ/scoreNow/scoreQuickWin/scorePotential/questions[题号]
questions[112]  — no/pillar(Zh)/sub(Zh)/subject/q/qEn/guideline/answer(yes|no|na)/
                  support/actionPlan/weight/isMinimumReq/hollow/
                  prefill{matched,source(platform|evidence|history|manual),sourceLabel,note}/
                  capabilityModule/ gap?{advice,fix(quick|mid|long)}/ cascade?{kind,note}
inbox[4]        — 7a 收件箱：srv-01 本卷 + SAQ5.0/CMRT/自定义问卷 3 条陪衬
```

## 三、注入映射（页面 ← 字段）

- **7a 收件箱** ← `inbox[]`（progress/score 已备）；
- **7b 支柱树** ← `pillars[]`（节点完成度 = 该支柱内 answer 统计；失分红点 = 有 gap 的题）；
- **7b 题目卡** ← `questions[]` 主体字段；"AI 预填"徽章 ← `prefill.matched`，徽章 tooltip ← `sourceLabel + note`；
- **7b 校验条** ← `meta.stats.checks`（未回答0 / 重复0 / 未填支持信息2 / 触红线0）——注意"2"是真实存在的，演示时是亮点不是瑕疵（第四幕入口）；
- **7b 右栏 AI 面板** ← `prefill.note` + `capabilityModule` + `gap.advice`；
- **7c 得分模拟** ← 三档分值（建议三段式条形：当前/快速整改/全部计划）；`meta.scoringNote` 放页脚小字（口径透明，防现场被将军）；
- **7c 差距清单** ← 26 条 gap（按 fix 分层排序 quick 在前）；行内"传导"按钮仅在有 `cascade` 时出现；
- **7c → datareq 抽屉**：抬头新增 `sourceSurveyQ: "客户P SSI Q8"`；12 个 cascade 动作按 kind 分流（datareq→数据请求单 / cmrt→CMRT收集 / training→培训任务 / audit→审核排程 / target→目标下发 / standard→准入标准）；
- **V2 来源徽章**：矩阵 8 指标中 ALV-E-004（绿电）可挂 "客户P SSI Q18-22"、ALV-S-002（矿产）挂 "Q62-68"、ALV-G-002（透明度）挂 "Q61/66"——三处即可，不必全挂。

## 四、红线与注意

1. **匿名恒定**：客户P/北欧OEM集团V 字样已写死在数据里，UI 层不要提供任何还原开关；
2. `guideline` 已截断至 400 字符（原文含长计算公式），够 tooltip 用；
3. 权重与红线来自问卷隐藏表真实还原（总权重 137，红线 = G>0 且 H=0 的 17 题），被追问可展开讲；
4. 得分算法是我们的演示口径（scoringNote 已声明），**不要**对客户宣称这是客户P官方算法；
5. 文件 ~103KB，作为 uploads 数据文件供 DC 读取或直接内联，勿整段贴进模板（HANDOFF 约定：大段写入用增量方式）。

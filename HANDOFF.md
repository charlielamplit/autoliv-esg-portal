# Handoff — Autoliv ESG Cockpit

供应链 ESG 合规工作台，服务外方管理层。单文件 DC：`Autoliv ESG Cockpit.dc.html`（模板 + 逻辑类 `Component`，~1300 行）。

## 设计基准
- 参考 ComplianceCenter（`/projects/5aede5ad-08ed-4ae4-98c2-2dcf61dbd7ed/docs/redesign/mockups/customer-demos/sdhi/07-compliance-center.html`）：224px 左侧边栏 + 顶栏面包屑 + 卡片语言 + water/leaf/earth/ink token。
- Autoliv 海军蓝 `#002D6B` 作品牌层。绿=达标、橙=进行、红=缺口。
- 字体：Plus Jakarta Sans / Manrope(数字) / Noto Sans SC / JetBrains Mono(编码)。
- **全内联样式**；helmet `<style>` 仅放 reset + 属性选择器开关（view/oem/lang/anon/drawer 切换）。

## 已完成（6 视图 + 4 抽屉，双语中/EN + 真实名↔匿名 OEM-01… 全局开关）
- **Shell**：侧边栏（品牌 / 工作台导航 5 项 / 自身合规导航 1 项 / 客户范围 OEM 列表 / 底部审核卡）+ 顶栏。
- **V1 总览**：Hub banner + 5 KPI + 双向传导图 + 减排进度 + 待办队列。选中 OEM 切「客户要求明细 + 档案 + 缺口整改」聚焦视图（`.only-all/.only-focus`）。聚焦视图「查看整改路径」按钮 → 要求抽屉。
- **V2 矩阵**：**8 指标（E×4·S×3·G×1）× 6 OEM**（吉利/长城/长安/小米/蔚来/奇瑞）承诺/请求/缺口热力矩阵，行可展开显示真实条款/出处/当前vs目标/负责人/证据/关联供应商。数据源自 `uploads/matrix_cells_副本.csv` + `matrix_detail_副本.csv`（已回填）。
- **V3 供应商**：五步流程 + 范围三饼图 + A–D 分级柱 + 供应商清单（含**真实组织名 + 头像 + 绿色评分进度条 + 评分构成 tooltip**）。行可点开供应商档案抽屉。
- **V4 合规雷达**：**8 metric_code × 6 OEM 热力图（E/S/G 色标，点格→要求抽屉）** + 「客户要求全景」卡（SAQ 5.0 人权12项 + RSCI 11模块）+ E/S/G 雷达 + 缺口预警列表（行可点）。
- **V5 报告导出**：客户报告生成向导（选客户/框架/区间→预览）+ 模板库（CDP/SBTi/客户模板）+ 历史报告库。
- **V6 法规合规图谱**（Autoliv 自身合规，`nav .n6`）：AI 扫描 CBAM/ISO14067/LkSG/EUDR/CSDDD/SBTi/RSCI，按强/中/已排除分级 + 「为什么适用」+ AI 顾问侧栏。行可点→法规义务抽屉。

## 抽屉（右侧滑出，4 类，统一任务模型）
`.dw-wrap[data-kind="…"]` 驱动显隐（kind ∈ supplier/requirement/action/reg/datareq）。
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
6. state 关键字段：`view, oem, lang, anon, matrixOpen, expandAll, repOem/repFw/repPeriod, drawer, dwKey`。
7. 逻辑 helper：`matrixData() / matrixDetail() / radarData() / supplierRaw() / supplierData() / drawerVals() / reqDetail() / reqFromMatrix() / actionDetail() / regVals() / regDetail() / dataReqFor() / reportVals() / focusProfile()`。

## 数据源（uploads/）
- `matrix_cells_副本.csv` / `matrix_detail_副本.csv`（8 指标×6 OEM，已回填 V2/V4）
- `OEM可持续供应链要求_调研详情.md`、`OEM_S维度要求专题_人权劳工与负责任采购.md`（条款出处底稿）

## 待办 / 下一步
- 已用 **mock 数据补全**：`supplierRaw()` 每家新增 `biz/riskK/site/contact`（年供货额/风险等级/生产基地/对接人），供应商档案抽屉 6 张 fact + 数据请求单抬头(对接人/基地)均取真值；anon 模式下基地/对接人隐去为「—」。
- 已用 **toast 补全交互**：`showToast(zh,en)` + state.toast；抽屉所有静态按钮（整改计划 / 标记完成·指派 / 生成整改任务·订阅触发流 / 发送请求单·PDF·存草稿）均 onClick 弹出确认 toast（2.8s 自动消失，底部居中）。如需真实动作再接后端。
- **仍需用户提供以贴近真实**：Autoliv 实际发给供应商的数据清单字段/填报周期/可接受证据类型（现为 7 项 mock）；矩阵 Autoliv 侧真实当前值（CMRT 覆盖率、SAQ 等级等，现为演示占位）。

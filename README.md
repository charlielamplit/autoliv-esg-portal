# Autoliv ESG 平台

供应链 ESG 合规平台（演示原型）。纯静态，无构建步骤。

> 2026-08-27 起主入口是 **Autoliv ESG 平台 v2**（`基础版 ⇄ 增强版` 两版对照）。
> 上一世代 Cockpit 仍在仓库作存档，但**已不再部署**，恢复方法见 `.vercelignore` 注释。

**仓库（唯一）**：https://github.com/charlielamplit/autoliv-esg-portal · private · 默认分支 `main`。所有更新提交到这里。

## 三个入口页

| 路径 | 入口页 | 源文件 | 内容 |
|---|---|---|---|
| `/` | `index.html` | `Autoliv ESG 平台 v2.dc.html` **+ 7 个 Plat 子 DC** | **ESG 平台（当前世代）**。根 DC 只装 shell + 全局 state + 路由，其余按需挂载，见下方 ⚠️。默认 `state.view='p2'`（达成与差距）；两条切换轴：版本 `基础版 ⇄ 增强版`、视角 `链主 ⇄ 供应商门户` |
| `/assi` | `assi.html` | `ASSI 线上供应商可持续问卷.dc.html` | 供应商视角的线上可持续问卷（133 题 / 6 支柱），带 Excel 导入导出 |
| `/ia` | `ia.html` | `Autoliv Demo 页面框架.dc.html` | 信息架构梳理讲解页（一级栏目 10 → 5 的现状与建议） |

`vercel.json` 开了 `cleanUrls`，所以 `/assi`、`/ia` 不带后缀也能访问。

## 文件

| 文件 | 作用 | 是否部署 |
|---|---|---|
| `PlatBase` / `PlatSystem` / `PlatGap` / `PlatSupply` / `PlatReg` / `PlatPortal` / `PlatDrawers`（`.dc.html`） | **7 个子 DC，运行时依赖**，根 DC 用 `<dc-import>` 加载 | ✓ |
| 其余 `*.dc.html`（平台根 DC / 平台 v1 / ASSI 源 / IA 源 / 整代 Cockpit 存档） | 纯编辑源与存档 | ✕ |
| `index.html` / `assi.html` / `ia.html` | 部署入口，由 `sync.sh` 生成 = 源文件副本 **+ defer 补丁**（见下） | ✓ |
| `support.js` | DC 运行时（运行时从 CDN 加载 React UMD） | ✓ |
| `assi-data.js` | `/assi` 的题库与演示数据，挂 `window.ASSI`（`QS`/`PIL`/`INFO`/`DEMO`/`HIST`） | ✓ |
| `data/*.json` | **运行时 fetch 的两个数据包**，见下方 ⚠️ | ✓ |
| `data/*.csv`、`data/*.md`、`uploads/` | 调研底稿（已回填进代码） | ✕ |
| `screenshots/` | 开发截图 | ✕ |
| `HANDOFF.md` | 实现细节与踩坑记录，**改代码前必读** | ✕ |

### ⚠️ 7 个子 DC 模块必须部署，且不能改名

2026-08-27 起主入口是「Autoliv ESG 平台 v2」，沿用「根 DC + 按需挂载子 DC」结构。
根 DC 里是 `<dc-import name="PlatDrawers">` 这样按**名字**引用，
`support.js` 把它解析成固定路径：

```js
COMPONENT_DIR = "."                                   // support.js:1552
url = COMPONENT_DIR + "/" + encodeURIComponent(name) + ".dc.html"   // :1576
```

所以这 7 个文件必须以**原名躺在站点根目录**：

```
PlatBase  PlatSystem  PlatGap  PlatSupply  PlatReg  PlatPortal  PlatDrawers
```

**漏部署或改名的表现是对应域整块空白**——不是报错、不是白屏，是那一块什么都没有，
控制台干净。所以 `.vercelignore` 里 DC 源文件只能逐个排除，**写 `*.dc.html` 会一次性
干掉这 7 个**，而本地和设计文件夹里文件都在，测不出来。

`sync.sh` 已加**两道**校验，任一不过直接 `exit 1`：① 7 个模块文件缺任一个；
② `index.html` 引用了 `MODULES` 里没登记的模块名（上游新加模块而这边漏登记时触发）。

### ⚠️ `data/` 下的两个 JSON 必须部署

平台世代在运行时 fetch：

```
./data/req_meta.json   ← 根 DC。台账条数(37)与四层供应商数(24/68/121/114=327)的唯一来源，
                          改这一个文件，界面上所有条数跟着走
./data/reg_demo.json   ← PlatReg。16 条法规 / 7 个业务节点 / 合规日历 / 出口管制
```

两个 fetch 都是 `.catch(()=>{})` —— **拿不到数据不会报错，只会静默降级**，页面看着正常但数字是 0 或列表是空的。
所以 `.vercelignore` 不能整目录排除 `data/`，用的是逐个排除底稿的写法。

> `supply_demo.json` / `survey_demo.json` / `supply_suppliers.json` 是上一世代 Cockpit 的数据包，
> 平台世代不再读，已排除出部署集。恢复 Cockpit 时要一并放回。

## sync.sh 的 defer 补丁（入口页与源文件唯一的差异）

`sync.sh` 生成 `assi.html` 时，会把 SheetJS 的 script 标签改成 `defer`
（**平台世代的 `index.html` 不加载 SheetJS，不打这个补丁**）：

```diff
- <script src="https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js"></script>
+ <script defer src="https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js"></script>
```

**为什么**：它在 `<helmet>` 里是普通 `<script src>`，**阻塞解析**，但只在用户点导出时才用得上。
实测首屏阻塞传输 548KB，它一个就占 **334KB（61%）**——解压后 952KB，比整个
index.html（brotli 后 152KB）还大一倍多。加 `defer` 后不再挡首屏渲染，而 DOMContentLoaded
前必定加载完，`window.XLSX` 在用户点导出时必然就绪，**行为零变化**。
（想进一步把这 334KB 也移出首屏，得改成点击时动态加载 + await，会动到 ASSI 页的
导入导出，风险是改错会静默退成 CSV，当前没做。）

**为什么打在 sync.sh 而不是 `.dc.html`**：源文件每轮都被设计文件夹整份覆盖，改那边会丢
（`HANDOFF.md` 已经这样丢过一次）。`sync.sh` 是仓库独有文件，改这里每轮自动生效。

**补丁匹配不到时 `sync.sh` 直接退出 1**，不会静默 no-op。所以哪天 DC 源换了 CDN 或加载方式，
你会立刻在同步这一步看到报错，而不是上线后才发现优化没了。

> 因此 **`assi.html` 不再与源文件字节相同**（`index.html` / `ia.html` 仍相同）。
> 校验 `assi.html` 时别比 md5，改成"差异必须只有 defer 这一行"：
> ```bash
> diff "ASSI 线上供应商可持续问卷.dc.html" assi.html | grep -E '^[<>]' | grep -vc sheetjs   # 必须是 0
> ```

## 改动流程

DC 编辑器的工作目录是 `…/ESGManagement/Autoliv ESG工作台设计/`，本仓库是它的部署镜像。

```bash
# 1. 在设计文件夹里用 DC 编辑器改 .dc.html
# 2. 拉回本仓库
DESIGN="../Autoliv ESG工作台设计"
cp "$DESIGN"/*.dc.html "$DESIGN"/assi-data.js "$DESIGN"/support.js .   # 注意：不含 HANDOFF.md
for d in data uploads screenshots; do rsync -a "$DESIGN/$d/" "$d/"; done
# 3. 同步入口页（必须，否则线上不会变）
./sync.sh
# 4. 提交推送，Vercel 自动部署
git add -A && git commit -m "..." && git push
```

#### ⚠️ `HANDOFF.md` 以本仓库为准，不要从设计文件夹覆盖

第 2 步是**从设计文件夹往仓库单向覆盖**，`.dc.html` / `assi-data.js` / `support.js`
都该这么拷。但 **`HANDOFF.md` 是例外**：

2026-08-02 补完 HANDOFF 后回写了设计文件夹，两边 md5 一致；到 08-03 那份又变回了
**补写之前的旧版本**（26729 bytes，字节级相同）—— DC 编辑器重建工作目录时会拿自己那份
覆盖掉。回写上游拦不住它，所以别再试。

结论：**`HANDOFF.md` 的权威副本在本仓库**，同步命令里已经把它排除。若哪天设计文件夹里
那份确实有人工新增内容，先 `diff` 再手工合并，不要整份 `cp`。

只属于仓库、设计文件夹没有的文件（`README.md` / `sync.sh` / `vercel.json` /
`.vercelignore` / 三个入口页）不受影响。

### ⚠️ 提交邮箱必须是 charlielamplit

Vercel 会校验 commit 作者邮箱对应的 GitHub 账号是否有本项目权限，**不匹配的提交会被拦下**
（部署状态显示 `Deployment was blocked`，不是构建失败，日志里看不出问题）。

本仓库已设好局部身份，正常不用管：

```bash
git config user.name    # → charlielamplit
git config user.email   # → charlielamplit@gmail.com
```

注意全局配置是另一个账号（`charlieccx@hotmail.com` → GitHub 用户 `CharlieCXC`），
**新克隆一份仓库时要重新设**，否则会继承全局值被拦：

```bash
git config user.name charlielamplit
git config user.email charlielamplit@gmail.com
```

万一 gmail 地址没在 GitHub 账号里验证过，改用一定能匹配的 noreply 地址：
`293292275+charlielamplit@users.noreply.github.com`

排查：`gh api repos/charlielamplit/autoliv-esg-portal/commits/<sha> --jq .author.login`
应返回 `charlielamplit`。

## 每次从设计文件夹同步后的自检清单

这几条都是真踩过的坑，且**共同点是不报错**——页面照常打开，只是内容不对，很容易一路带到线上。

**1. 新增的 `.dc.html` 是否已加进 `sync.sh`，以及入口页差异是否只有 defer**
漏加 = 源文件进了仓库但没有对应入口页，线上访问 404 或停在旧版。
`sync.sh` 跑完必须退出 0（`defer` 补丁匹配不到会退出 1，见上节），再确认差异只有那一行：

```bash
diff "Autoliv ESG 平台 v2.dc.html" index.html | wc -l                              # 必须是 0
diff "ASSI 线上供应商可持续问卷.dc.html" assi.html | grep -E '^[<>]' | grep -vc sheetjs   # 必须是 0
```

**2. 新出现的运行时依赖是否被 `.vercelignore` 挡住**（本轮就栽在这条）
每次同步后跑一遍，把结果和 `.vercelignore` 对一遍。注意 `dc-import` 是按**名字**引用、
不带 `./`，所以要单独扫一次：

```bash
# 只扫「当前世代实际会加载的文件」—— 别 glob *.dc.html，那会把存档的 Cockpit 源
# 一起扫进来，报一堆用不到的依赖（supply_demo.json / CockpitDrawers 之类），是误报。
SCAN=(index.html assi.html ia.html Plat*.dc.html)

# 相对路径依赖（script src / fetch / iframe）
grep -ohE 'src="\./[^"]+"|fetch\('"'"'\./[^'"'"']+' "${SCAN[@]}" | grep -oE '\./[^"'"'"']+' | sort -u
# 子 DC 模块依赖 → 每个都必须有同名 .dc.html 且在部署集里
grep -ohE '<dc-import name="[^"]+"' index.html | sed 's/.*name="//;s/"$//' | sort -u
# 反推真实部署集，逐个核对上面两组
comm -23 <(git ls-files|sort) <(git ls-files -c -i --exclude-from=.vercelignore|sort)
```

平台的两个 `fetch` 都是 `.catch(()=>{})`，`assi.html` 的 `window.ASSI` 拿不到也只是空题库——
**漏部署一律静默降级成空列表/零值，控制台干净、构建成功、看不出任何异常**。

历史提醒：Cockpit 世代还有一处 `iframe` 内嵌 `./ASSI%20线上供应商可持续问卷.dc.html`
（源文件本身，不是 `assi.html`），所以那时 ASSI 源必须部署。**平台世代不再内嵌**，
该源已排除出部署集 —— 若哪天恢复 Cockpit，记得把它放回。

**3. `assi-data.js` 的数据契约**
`ASSI 线上供应商可持续问卷.dc.html` 读 `window.ASSI` 的 `QS`/`PIL`/`INFO`/`DEMO`/`HIST` 五个键，
换题库时确认键名没变：

```bash
node -e "global.window={};require('./assi-data.js');console.log(Object.keys(window.ASSI))"
```

**4. 起 http server 逐个验 200**（见下节），别只开首页——
`data/*.json`、`assi-data.js` 这类资源正是最容易漏的。

**5. 提交身份是 `charlielamplit`**（见上节）。

## 本地预览

```bash
python3 -m http.server 8080
# http://localhost:8080/          ESG 平台
# http://localhost:8080/assi.html 供应商问卷
# http://localhost:8080/ia.html   信息架构
```

必须走 HTTP server：`file://` 打开时 `data/*.json` 的 fetch 会被 CORS 拦掉（静默失败，见上）。

## Vercel 部署设置

- Framework Preset: **Other**
- Build Command / Output Directory / Install Command：均留空（根目录直出）

运行时需联网加载：

- **React 18.3.1 UMD（`unpkg.com`）** —— 硬依赖，拿不到就白屏。
- **Google Fonts** —— 掉了只是回落系统字体。
- **SheetJS 0.20.3（`cdn.sheetjs.com`）** —— **只有 `/assi` 用**（问卷 Excel 导入导出）；
  平台世代的 `/` 不加载它。ASSI 页做了降级：`window.XLSX` 不在时自动改导出带 BOM 的
  等价 CSV 并 toast 说明，所以 CDN 挂了不影响演示，只是格式退化。

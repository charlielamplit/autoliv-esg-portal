# Autoliv ESG Cockpit

供应链 ESG 合规工作台（演示原型）。纯静态，无构建步骤。

**仓库（唯一）**：https://github.com/charlielamplit/autoliv-esg-portal · private · 默认分支 `main`。所有更新提交到这里。

## 三个入口页

| 路径 | 入口页 | 源文件 | 内容 |
|---|---|---|---|
| `/` | `index.html` | `Autoliv ESG Cockpit.dc.html` | 工作台主体，13 个视图（v1–v13）。加载后默认 `state.view='v1'` 总览驾驶舱 |
| `/assi` | `assi.html` | `ASSI 线上供应商可持续问卷.dc.html` | 供应商视角的线上可持续问卷（133 题 / 6 支柱），带 Excel 导入导出 |
| `/ia` | `ia.html` | `Autoliv Demo 页面框架.dc.html` | 信息架构梳理讲解页（一级栏目 10 → 5 的现状与建议） |

`vercel.json` 开了 `cleanUrls`，所以 `/assi`、`/ia` 不带后缀也能访问。

## 文件

| 文件 | 作用 | 是否部署 |
|---|---|---|
| `*.dc.html` | **编辑源文件**（DC 模板 + `Component` 逻辑类） | ✕ |
| `index.html` / `assi.html` / `ia.html` | 部署入口，源文件的副本，由 `sync.sh` 生成 | ✓ |
| `support.js` | DC 运行时（运行时从 CDN 加载 React UMD） | ✓ |
| `assi-data.js` | `/assi` 的题库与演示数据，挂 `window.ASSI`（`QS`/`PIL`/`INFO`/`DEMO`/`HIST`） | ✓ |
| `data/*.json` | **`index.html` 运行时 fetch 的三个数据包**，见下方 ⚠️ | ✓ |
| `data/*.csv`、`data/*.md`、`uploads/` | 调研底稿（已回填进代码） | ✕ |
| `screenshots/` | 开发截图 | ✕ |
| `HANDOFF.md` | 实现细节与踩坑记录，**改代码前必读** | ✕ |

### ⚠️ `data/` 下的三个 JSON 必须部署

`index.html` 在 `componentDidMount` 里 fetch：

```
./data/supply_suppliers.json   317 家供应商精简集（V7 散点/下钻/抽屉）
./data/survey_demo.json        112 题客户问卷包（V11 客户问卷线）
./data/supply_demo.json        37 项要求 / 317 家 / 聚合 / MOFCOM / 尽调
```

三个 fetch 都是 `.catch(()=>{})` —— **拿不到数据不会报错，只会静默降级**，页面看着正常但列表是空的。
所以 `.vercelignore` 不能再整目录排除 `data/`（旧版工作台数据全内联、没有 fetch，那时可以排）。
现在改成逐个排除底稿文件，新增数据包默认会被部署。

## 改动流程

DC 编辑器的工作目录是 `…/ESGManagement/Autoliv ESG工作台设计/`，本仓库是它的部署镜像。

```bash
# 1. 在设计文件夹里用 DC 编辑器改 .dc.html
# 2. 拉回本仓库
DESIGN="../Autoliv ESG工作台设计"
cp "$DESIGN"/*.dc.html "$DESIGN"/assi-data.js "$DESIGN"/support.js "$DESIGN"/HANDOFF.md .
for d in data uploads screenshots; do rsync -a "$DESIGN/$d/" "$d/"; done
# 3. 同步入口页（必须，否则线上不会变）
./sync.sh
# 4. 提交推送，Vercel 自动部署
git add -A && git commit -m "..." && git push
```

⚠️ 第 2 步是**从设计文件夹往仓库单向覆盖**。`HANDOFF.md`、`.dc.html`、`assi-data.js`
在两边各有一份，**只改仓库这边会在下次同步时被静默盖掉**。要改这些文件，
改完记得回写设计文件夹（`cp HANDOFF.md "$DESIGN"/`），或者干脆在设计文件夹里改。
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

**1. 新增的 `.dc.html` 是否已加进 `sync.sh`**
漏加 = 源文件进了仓库但没有对应入口页，线上访问 404 或停在旧版。

**2. 新出现的运行时依赖是否被 `.vercelignore` 挡住**（本轮就栽在这条）
每次同步后跑一遍，把结果和 `.vercelignore` 对一遍：

```bash
grep -ohE 'src="\./[^"]+"|fetch\('"'"'\./[^'"'"']+' *.dc.html | grep -oE '\./[^"'"'"']+' | sort -u
```

工作台的三个 `fetch` 全是 `.catch(()=>{})`，`assi.html` 的 `window.ASSI` 拿不到也只是空题库——
**漏部署一律静默降级成空列表，控制台干净、构建成功、看不出任何异常**。

同理还有一处 `iframe`：工作台「供应商问卷 → ASSI」标签页内嵌的是
`./ASSI%20线上供应商可持续问卷.dc.html`（源文件本身，不是 `assi.html`），
所以 `.vercelignore` 里 DC 源文件只能**逐个排除**，写成 `*.dc.html` 会把它一起排掉、
线上 iframe 变 404，而本地文件都在、完全测不出来。要改这个文件名先改 iframe。

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
# http://localhost:8080/          工作台
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
- **SheetJS 0.20.3（`cdn.sheetjs.com`）** —— `/` 和 `/assi` 都用（前者按客户模板导出问卷
  `exportSurvey()`，后者做问卷 Excel 导入导出）。**两个页面都做了降级**：`window.XLSX`
  不在时自动改导出带 BOM 的等价 CSV 并 toast 说明，所以 CDN 挂了不影响演示，只是格式退化。

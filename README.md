# Autoliv ESG Cockpit

供应链 ESG 合规工作台（演示原型）。纯静态单页，无构建步骤。

**首页即总览驾驶舱**：`index.html` 加载后默认 `state.view = 'v1'`（总览驾驶舱），访问根路径 `/` 直接进入。

## 文件

| 文件 | 作用 |
|---|---|
| `Autoliv ESG Cockpit.dc.html` | **编辑源文件**（DC 模板 + `Component` 逻辑类） |
| `index.html` | 部署入口，源文件的副本，由 `sync.sh` 生成 |
| `support.js` | DC 运行时（运行时从 CDN 加载 React UMD） |
| `data/`、`uploads/` | 数据底稿与调研文档，**不部署**（见 `.vercelignore`） |
| `screenshots/` | 开发截图，不部署 |
| `HANDOFF.md` | 实现细节与踩坑记录，改代码前必读 |

## 改动流程

```bash
# 1. 编辑 "Autoliv ESG Cockpit.dc.html"
# 2. 同步入口页（必须，否则线上不会变）
./sync.sh
# 3. 提交推送，Vercel 自动部署
git add -A && git commit -m "..." && git push
```

## 本地预览

```bash
python3 -m http.server 8080
# 打开 http://localhost:8080/
```

必须走 HTTP server，直接 `file://` 打开会因为跨域拿不到 React CDN 之外的资源。

## Vercel 部署设置

- Framework Preset: **Other**
- Build Command: 留空
- Output Directory: 留空（根目录）
- Install Command: 留空

运行时需联网加载 React 18.3.1 UMD（`unpkg.com`）与 Google Fonts。

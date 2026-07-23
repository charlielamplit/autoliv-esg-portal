# Autoliv ESG Cockpit

供应链 ESG 合规工作台（演示原型）。纯静态单页，无构建步骤。

**仓库（唯一）**：https://github.com/charlielamplit/autoliv-esg-portal · private · 默认分支 `main`。所有更新提交到这里。

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

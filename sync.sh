#!/usr/bin/env bash
# 把 DC 编辑源文件同步为 Vercel 的入口页。改完任一 .dc.html 后、提交前跑一次。
# 入口页文件名保持 ASCII，配合 vercel.json 的 cleanUrls 得到 / 、/assi 、/ia 三条路径。
set -euo pipefail
cd "$(dirname "$0")"

sync() {  # sync <源 .dc.html> <入口页>
  cp "$1" "$2"
  printf '  %-38s → %s\n' "$1" "$2"
}

sync "Autoliv ESG Cockpit.dc.html"      index.html   # /      总览驾驶舱（工作台主入口）
sync "ASSI 线上供应商可持续问卷.dc.html"  assi.html    # /assi  供应商可持续问卷（供应商视角独立页）
sync "Autoliv Demo 页面框架.dc.html"     ia.html      # /ia    信息架构梳理（演示讲解页）

echo "✓ 3 个入口页已同步"

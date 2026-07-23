#!/usr/bin/env bash
# 把编辑源文件同步为 Vercel 的入口页。改完 .dc.html 后、提交前跑一次。
set -euo pipefail
cd "$(dirname "$0")"
cp "Autoliv ESG Cockpit.dc.html" index.html
echo "✓ index.html 已同步（部署首页 = 总览驾驶舱 V1）"

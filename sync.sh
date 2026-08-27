#!/usr/bin/env bash
# 把 DC 编辑源文件同步为 Vercel 的入口页。改完任一 .dc.html 后、提交前跑一次。
# 入口页文件名保持 ASCII，配合 vercel.json 的 cleanUrls 得到 / 、/assi 、/ia 三条路径。
#
# 入口页 = 源文件副本（+ 需要时的 defer 补丁，见下）。
set -euo pipefail
cd "$(dirname "$0")"

# ── defer 补丁 ────────────────────────────────────────────────────────────
# SheetJS 在 <helmet> 里是普通 <script src>，会阻塞解析，却只在点导出时才用到。
# 加 defer 后不再挡首屏，且 DOMContentLoaded 前必定加载完，window.XLSX 在用户
# 点导出时必然就绪 —— 行为不变。补丁打在生成入口页这一步、不改 .dc.html：
# 源文件每轮都会被设计文件夹整份覆盖，改那边会丢。
#
# 只对「确实加载了 SheetJS」的入口页调用（见下方 sync 的第三参数）。
# 平台 v2 这一代不用 SheetJS，所以它不传 defer。
defer_sheetjs() {
  python3 - "$1" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '<script src="https://cdn.sheetjs.com/'
new = '<script defer src="https://cdn.sheetjs.com/'
if old not in s:
    sys.exit('  ✗ %s 里没找到预期的 SheetJS script 标签。\n'
             '    该入口页在 sync.sh 里被标了 defer，说明它本该加载 SheetJS。\n'
             '    要么 DC 源改了加载方式，要么这个 defer 标记该去掉 —— 先核对再提交。' % p)
n = s.count(old)
io.open(p, 'w', encoding='utf-8').write(s.replace(old, new))
print('      ↳ SheetJS 已加 defer ×%d' % n)
PY
}

sync() {  # sync <源 .dc.html> <入口页> [defer]
  cp "$1" "$2"
  printf '  %-38s → %s\n' "$1" "$2"
  [ "${3:-}" = "defer" ] && defer_sheetjs "$2"
  return 0
}

# ── 入口页 ────────────────────────────────────────────────────────────────
# 2026-08-27 起主入口改为「Autoliv ESG 平台 v2」（与 Cockpit 系列完全独立、
# 不共用文件）。根 DC 只装 shell + 全局 state + 路由，其余按 <dc-import name="X">
# 从同目录的 X.dc.html 按需挂载。那 7 个模块**不经 sync.sh 处理**，以原名原样
# 部署 —— support.js 写死了 COMPONENT_DIR="." + name + ".dc.html"，改名即 404。
sync "Autoliv ESG 平台 v2.dc.html"      index.html        # /      ESG 平台（主入口）
sync "ASSI 线上供应商可持续问卷.dc.html"  assi.html  defer  # /assi  供应商可持续问卷（独立演示页）
sync "Autoliv Demo 页面框架.dc.html"     ia.html           # /ia    信息架构梳理（不加载 SheetJS）

# ── 子 DC 模块校验 ────────────────────────────────────────────────────────
# 模块缺失的表现是「对应域整块空白、控制台干净」，属最难发现的一类，所以硬失败。
MODULES="PlatBase PlatSystem PlatGap PlatSupply PlatReg PlatPortal PlatDrawers"
missing=0
for m in $MODULES; do
  grep -q "dc-import name=\"$m\"" index.html \
    || echo "  ⚠ index.html 不再引用模块 $m —— 若已废弃，记得同时更新 .vercelignore 的说明"
  [ -f "$m.dc.html" ] || { echo "  ✗ 缺少模块文件 $m.dc.html"; missing=1; }
done
# 反向：index.html 引用了但 MODULES 没列到的，同样要拦
for n in $(grep -ohE '<dc-import name="[^"]+"' index.html | sed 's/.*name="//;s/"$//' | sort -u); do
  echo "$MODULES" | tr ' ' '\n' | grep -qx "$n" \
    || { echo "  ✗ index.html 引用了未登记的模块 $n（sync.sh 的 MODULES 与 .vercelignore 都要补）"; missing=1; }
done
[ "$missing" = "0" ] || { echo "    子 DC 缺失/漏登记会让对应域整块空白且不报错，已中止。"; exit 1; }

echo "✓ 3 个入口页 + 7 个子 DC 模块已就位"

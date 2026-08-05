#!/usr/bin/env bash
# 把 DC 编辑源文件同步为 Vercel 的入口页。改完任一 .dc.html 后、提交前跑一次。
# 入口页文件名保持 ASCII，配合 vercel.json 的 cleanUrls 得到 / 、/assi 、/ia 三条路径。
#
# 入口页 = 源文件副本 + 下面的 defer 补丁（所以入口页与 .dc.html 不再字节相同，
# 唯一差异就是 SheetJS 那个 script 标签多了 defer，见 README）。
set -euo pipefail
cd "$(dirname "$0")"

# SheetJS 占首屏阻塞传输的 61%（334KB / 548KB），却只在点导出时才用得上，
# 而它在 <helmet> 里是普通 <script src>，会阻塞解析。加 defer 即可不再挡首屏，
# 且 DOMContentLoaded 前一定加载完，window.XLSX 在用户点导出时必然就绪 —— 行为不变。
#
# 补丁打在生成入口页这一步、不改 .dc.html：源文件每轮都会被设计文件夹整份覆盖，
# 改在那边会丢；sync.sh 是仓库独有文件，改这里每轮自动生效。
defer_sheetjs() {  # defer_sheetjs <入口页>
  python3 - "$1" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '<script src="https://cdn.sheetjs.com/'
new = '<script defer src="https://cdn.sheetjs.com/'
if old not in s:
    sys.exit('  ✗ %s 里没找到预期的 SheetJS script 标签。\n'
             '    DC 源可能改了它的加载方式 —— defer 补丁没打上，请先核对 sync.sh 再提交。' % p)
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

# 2026-08-05 起工作台入口改用拆分版 v2：根 DC 只装 shell + 全局 state + 路由，
# 其余按 <dc-import name="X"> 从同目录的 X.dc.html 按需挂载（首屏节点 2728 → 1158）。
# 那 7 个模块**不经 sync.sh 处理**，以原名原样部署 —— support.js 写死了
# COMPONENT_DIR="." + name + ".dc.html"，路径必须逐字对上，改名即 404。
sync "Autoliv ESG Cockpit v2.dc.html"   index.html defer  # /      总览驾驶舱（工作台主入口）
sync "ASSI 线上供应商可持续问卷.dc.html"  assi.html  defer  # /assi  供应商可持续问卷（供应商视角独立页）
sync "Autoliv Demo 页面框架.dc.html"     ia.html           # /ia    信息架构梳理（不加载 SheetJS）

# 子 DC 模块必须存在且能被 index.html 找到，否则对应域整块空白（无报错）。
missing=0
for m in CockpitCustomerDomain CockpitSupplierDomain CockpitPortal \
         CockpitReportDomain CockpitRegulatoryDomain CockpitLedgerDomain CockpitDrawers; do
  if ! grep -q "dc-import name=\"$m\"" index.html; then
    echo "  ⚠ index.html 不再引用模块 $m —— 若已废弃，记得同时从 .vercelignore 的说明里去掉"; fi
  [ -f "$m.dc.html" ] || { echo "  ✗ 缺少模块文件 $m.dc.html"; missing=1; }
done
[ "$missing" = "0" ] || { echo "    子 DC 缺失会让对应域整块空白且不报错，已中止。"; exit 1; }

echo "✓ 3 个入口页 + 7 个子 DC 模块已就位"

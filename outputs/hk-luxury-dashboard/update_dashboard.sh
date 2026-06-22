#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/landz/Documents/Codex/2026-06-18/ai-agent-30-skills-ai-identity"
PY="/Users/landz/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
WORKBOOK="/Users/landz/Desktop/香港中原成交明细_四表整合版.xlsx"
OUT_DIR="$ROOT/outputs/hk-luxury-dashboard"
TODAY="$(TZ=Asia/Hong_Kong date +%F)"
MONTH_START="$(TZ=Asia/Hong_Kong date +%Y-%m-01)"

cd "$ROOT"

"$PY" work/hk-luxury-dashboard/fetch_centaline_today.py \
  --start-date "$MONTH_START" \
  --end-date "$TODAY" \
  --out-dir "$OUT_DIR" \
  --max-pages 140

"$PY" work/hk-luxury-dashboard/fetch_centaline_indices.py \
  --out-dir "$OUT_DIR"

"$PY" work/hk-luxury-dashboard/fetch_centaline_listings.py \
  --out-dir "$OUT_DIR" \
  --max-pages 30

"$PY" work/hk-luxury-dashboard/generate_dashboard_data.py \
  --workbook "$WORKBOOK" \
  --live-json "$OUT_DIR/centaline-live-transactions.json" \
  --index-json "$OUT_DIR/centaline-index-data.json" \
  --listing-json "$OUT_DIR/centaline-live-listings.json" \
  --template work/hk-luxury-dashboard/dashboard.template.html \
  --out-dir "$OUT_DIR"

echo "香港豪宅每日成交看板已更新：$TODAY"

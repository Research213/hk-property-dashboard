#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/landz/Documents/Codex/2026-06-18/ai-agent-30-skills-ai-identity"
PY="/Users/landz/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
OUT_DIR="$ROOT/outputs/hk-luxury-dashboard"
OWNER="Research213"
REPO="hk-property-dashboard"
SRC="$OUT_DIR/index.html"
PAYLOAD="/private/tmp/hk_property_dashboard_pages_payload.json"

cd "$ROOT"

"$OUT_DIR/update_dashboard.sh"

SHA="$(gh api "repos/$OWNER/$REPO/contents/index.html" --jq .sha 2>/dev/null || true)"

"$PY" - "$SRC" "$PAYLOAD" "$SHA" <<'PY'
import base64
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
payload = Path(sys.argv[2])
sha = sys.argv[3]
data = {
    "message": "Update Hong Kong property dashboard",
    "content": base64.b64encode(src.read_bytes()).decode("ascii"),
    "branch": "main",
}
if sha:
    data["sha"] = sha
payload.write_text(json.dumps(data), encoding="utf-8")
PY

gh api --method PUT "repos/$OWNER/$REPO/contents/index.html" --input "$PAYLOAD" --jq .content.html_url

echo "公开链接：https://$OWNER.github.io/$REPO/"

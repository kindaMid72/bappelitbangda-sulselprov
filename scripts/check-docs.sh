#!/usr/bin/env bash
# 1. Every doc under docs/ (except docs/schema/ and docs/README.md) needs a Status and Last reviewed header
#    in its first 15 lines, and must be listed in docs/README.md.
# 2. The requirement ids in docs/prd/traceability.md must equal the ids in docs/prd/PRD.md.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

while IFS= read -r f; do
  case "$f" in docs/schema/*|docs/README.md) continue ;; esac
  head -n 15 "$f" | grep -qiE '^status:' || { echo "missing 'Status:' header in $f"; fail=1; }
  head -n 15 "$f" | grep -qiE '^last reviewed:' || { echo "missing 'Last reviewed:' header in $f"; fail=1; }
  # docs/README.md must link the path relative to docs/ (basenames collide: several README.md files)
  rel="${f#docs/}"
  grep -qF "($rel)" docs/README.md || grep -qF "\`$rel\`" docs/README.md || { echo "$f is not listed in docs/README.md"; fail=1; }
done < <(find docs -name '*.md' -type f | sort)

prd=docs/prd/PRD.md
tr=docs/prd/traceability.md
if [ -f "$prd" ] && [ -f "$tr" ]; then
  prd_ids="$(grep -oE '^\| (N?FR-[0-9]+) \|' "$prd" | grep -oE 'N?FR-[0-9]+' | sort -u)"
  tr_ids="$(grep -oE '^\| (N?FR-[0-9]+) \|' "$tr" | grep -oE 'N?FR-[0-9]+' | sort -u)"
  if [ "$prd_ids" != "$tr_ids" ]; then
    echo "traceability ids differ from the PRD:"
    diff <(echo "$prd_ids") <(echo "$tr_ids") || true
    fail=1
  fi
  nfr="$(echo "$prd_ids" | grep -c '^NFR')"; fr="$(echo "$prd_ids" | grep -vc '^NFR')"
  echo "docs-check: PRD has $fr FR and $nfr NFR ids; traceability matches: $([ "$fail" -eq 0 ] && echo yes || echo NO)"
else
  echo "docs-check: skipped traceability comparison (missing $prd or $tr)"
fi
exit "$fail"

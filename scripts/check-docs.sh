#!/usr/bin/env bash
# The requirement ids in docs/prd/traceability.md must equal the ids in docs/prd/PRD.md.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

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

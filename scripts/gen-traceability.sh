#!/usr/bin/env bash
# Generates docs/prd/traceability.md from docs/prd/PRD.md (ids, titles, priorities, phases, OQ dependencies).
# Existing issue/test/status columns are NOT preserved: run this only to create the table or after a PRD version bump,
# then re-enter links by hand (or merge with git). `scripts/check-docs.sh` verifies the id list stays equal to the PRD.
set -euo pipefail
cd "$(dirname "$0")/.."
prd="docs/prd/PRD.md"
out="docs/prd/traceability.md"

# Phase lists come from PRD section 9 (the table row starting with the phase name).
phase_ids() { grep -E "^\| $1" "$prd" | head -n 1 | awk -F'|' '{print $4}' | grep -oE 'FR-[0-9]+|[0-9]+' | tr '\n' ' '; }
mvp_fr=" $(grep -E '^\| 1\\\\\. MVP' "$prd" | awk -F'|' '{print $4}' | sed 's/FR-//; s/,/ /g') "
p2_fr=" $(grep -E '^\| 2\\\\\. Strengthening' "$prd" | awk -F'|' '{print $4}' | sed 's/FR-//; s/,/ /g') "
p3_fr=" $(grep -E '^\| 3\\\\\. Additions' "$prd" | awk -F'|' '{print $4}' | sed 's/FR-//; s/,/ /g') "
# NFR Must list: "NFR-01, 03, 04, ..." from the sentence after the phase table.
mvp_nfr=" $(grep -E '^The non-functional requirements that are conditions for the MVP release:' "$prd" | sed -E 's/.*release: ([^.]*)\..*/\1/; s/NFR-//; s/,//g; s/ and / /') "

{
  echo "Status: generated"
  echo "Last reviewed: $(date +%F)"
  echo
  echo "# Traceability: PRD requirement to issues and tests"
  echo
  echo "Generated from \`docs/prd/PRD.md\` by \`scripts/gen-traceability.sh\`. Fill the issue, test and status columns by hand."
  echo "\`make docs-check\` fails if the id list here differs from the PRD (45 FR, 17 NFR)."
  echo
  echo "| Id | Title (PRD words) | Priority | Phase | Status | Issue | Test | Notes (OQ dependencies) |"
  echo "|---|---|---|---|---|---|---|---|"
  grep -E '^\| (FR|NFR)-[0-9]+ \|' "$prd" | awk -F'|' -v mvp_fr="$mvp_fr" -v p2="$p2_fr" -v p3="$p3_fr" -v mvp_nfr="$mvp_nfr" '
    function trim(s) { gsub(/^ +| +$/, "", s); return s }
    {
      id = trim($2); num = id; sub(/^N?FR-/, "", num); n = num + 0
      isnfr = (id ~ /^NFR/)
      if (isnfr) { title = trim($4); prio = trim($(NF-1)) } else { title = trim($3); prio = trim($4) }
      key = " " sprintf("%02d", n) " "; key2 = " " n " "
      if (isnfr) {
        phase = (index(mvp_nfr, key) || index(mvp_nfr, key2)) ? "MVP gate" : "Should (not a release gate)"
      } else if (index(mvp_fr, key2) || index(mvp_fr, key)) { phase = "1 MVP" }
      else if (index(p2, key2) || index(p2, key)) { phase = "2 Strengthening" }
      else if (index(p3, key2) || index(p3, key)) { phase = "3 Additions" }
      else { phase = "Deferred (Won\x27t)" }
      row = $0; oq = ""
      while (match(row, /OQ-[0-9]+/)) { t = substr(row, RSTART, RLENGTH); if (index(oq, t) == 0) oq = oq (oq == "" ? "" : ", ") t; row = substr(row, RSTART + RLENGTH) }
      gsub(/\|/, "/", title)
      printf "| %s | %s | %s | %s | not started |  |  | %s |\n", id, title, prio, phase, oq
    }'
} > "$out"
echo "wrote $out ($(grep -cE '^\| (FR|NFR)-' "$out") rows)"

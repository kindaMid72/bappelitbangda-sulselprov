#!/usr/bin/env bash
# UNTESTED ON THE VPS: run on staging first.
# Post-deploy checks against a running stack.   Usage: smoke.sh <base-url>   (for example http://localhost:8081)
# TODO: one authenticated call on staging once login exists (FR-33); EICAR upload check once NFR-06 scanning exists.
set -euo pipefail

base="${1:?usage: smoke.sh <base-url>}"
base="${base%/}"
fail=0

check() { # check <name> <command...>
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "smoke: ok   $name"; else echo "smoke: FAIL $name"; fail=1; fi
}

# shellcheck disable=SC2329  # called indirectly through check()
body_has() { curl -fsS --max-time 10 "$1" | grep -q "$2"; }

check "API health"           body_has "$base/api/v1/health" '"status":"ok"'
check "home page renders"    body_has "$base/" "Bappelitbangda"
check "home page shows API"  body_has "$base/" "berjalan"
check "unknown path is 404"  test "$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$base/no-such-page-xyz")" = "404"

exit "$fail"

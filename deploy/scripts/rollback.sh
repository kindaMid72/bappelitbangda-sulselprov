#!/usr/bin/env bash
# UNTESTED ON THE VPS: run on staging first.
# Redeploys the previous application version (its images are kept by deploy.sh).
# Migrations are NOT rolled back. If the last migration was not backward compatible, restore from backup instead
# (target recovery time 4 hours, NFR-10) and run a Down only after review.
# Usage: rollback.sh [--profile staging|prod] [--dry-run]
set -euo pipefail
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
. "$DEPLOY_DIR/scripts/lib.sh"

profile=staging
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) shift; profile="${1:-}" ;;
    --dry-run) DRY_RUN=1 ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done
profile_suffix "$profile" >/dev/null
export DRY_RUN
case "$profile" in prod) smoke_url="http://localhost:${PROD_PORT:-80}" ;; *) smoke_url="http://localhost:${STAGING_PORT:-8081}" ;; esac

current="$(read_state "$profile" current)"
previous="$(read_state "$profile" previous)"
if [ -z "$previous" ]; then
  if [ "$DRY_RUN" = "1" ]; then previous="<previous>"; else die "no previous version recorded for $profile"; fi
fi
log "rollback $profile: ${current:-unknown} -> $previous"

if [ "$DRY_RUN" != "1" ]; then
  for name in api web migrate; do
    docker image inspect "bappelitbangda-$name:$previous" >/dev/null 2>&1 || die "image bappelitbangda-$name:$previous is not on this server"
  done
fi
VERSION="$previous" run compose "$profile" up -d
smoke_with_retry "$smoke_url" || die "smoke test failed after rollback"
write_state "$profile" current "$previous"
[ -z "$current" ] || write_state "$profile" previous "$current"
VERSION="$previous" log_deploy "$previous" "$profile" "rollback from ${current:-unknown}"

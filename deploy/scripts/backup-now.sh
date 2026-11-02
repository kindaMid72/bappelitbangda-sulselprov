#!/usr/bin/env bash
# UNTESTED ON THE VPS: run on staging first.
# Encrypted database backup (NFR-10, NFR-17).   Usage: backup-now.sh [--profile staging|prod] [--dry-run]
# Backups are encrypted with `age` to a PUBLIC recipient key; the private key is held off the VPS (OQ-17).
# This script refuses to write an unencrypted backup. Copying the file off the server is a separate, human step
# (target: OQ-04 / Appendix D "outside the application server").
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
suffix="$(profile_suffix "$profile")"

: "${BACKUP_AGE_RECIPIENT:?set BACKUP_AGE_RECIPIENT to the public age key (private key stays off the VPS)}"
command -v age >/dev/null || [ "$DRY_RUN" = "1" ] || die "age is not installed"

out="$BACKUP_DIR/db-$profile-$(date +%Y%m%dT%H%M%S).dump.age"
run mkdir -p "$BACKUP_DIR"
if [ "$DRY_RUN" = "1" ]; then
  echo "[dry-run] docker exec db$suffix pg_dump -Fc | age -r <recipient> > $out"
else
  # shellcheck disable=SC2016  # the variables are expanded inside the container
  VERSION="${VERSION:-current}" compose "$profile" exec -T "db$suffix" sh -c 'pg_dump -Fc -U "$POSTGRES_USER" "$POSTGRES_DB"' \
    | age -r "$BACKUP_AGE_RECIPIENT" > "$out"
  chmod 0600 "$out"
  log "backup written: $out ($(wc -c < "$out") bytes)"
fi

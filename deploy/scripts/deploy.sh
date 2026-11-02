#!/usr/bin/env bash
# UNTESTED ON THE VPS: run on staging first.
# Deploys a release bundle on THIS server. GitHub never deploys and the VPS holds no GitHub credentials:
# a maintainer copies the bundle here (scp) and runs this script. See docs/workflow/team-and-agents.md section 14.
#
# Usage: deploy.sh <version> [--profile staging|prod] [--dry-run]
# Run it from the extracted bundle: <bundle>/deploy/scripts/deploy.sh v0.1.0 --profile staging
# Needs: docker (compose v2), jq, sha256sum, curl. Environment files live in $INSTALL_DIR (default /opt/bappelitbangda).
set -euo pipefail
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="$(cd "$DEPLOY_DIR/.." && pwd)"
# shellcheck source=lib.sh
. "$DEPLOY_DIR/scripts/lib.sh"

version="${1:-}"; [ -n "$version" ] || die "usage: deploy.sh <version> [--profile staging|prod] [--dry-run]"
shift
profile=staging
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) shift; profile="${1:-}" ;;
    --dry-run) DRY_RUN=1 ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done
[[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.]+)?$ ]] || die "version must look like v1.2.3"
suffix="$(profile_suffix "$profile")"
export VERSION="$version" DRY_RUN
case "$profile" in prod) smoke_url="http://localhost:${PROD_PORT:-80}" ;; *) smoke_url="http://localhost:${STAGING_PORT:-8081}" ;; esac

log "deploy $version to $profile (dry-run=$DRY_RUN)"
for cmd in docker jq sha256sum curl; do command -v "$cmd" >/dev/null || [ "$DRY_RUN" = "1" ] || die "$cmd is required"; done

# 1. Preconditions
min_free_gb="${MIN_FREE_GB:-5}"
disk_dir="$INSTALL_DIR"; [ -d "$disk_dir" ] || disk_dir=/
free_gb="$(df --output=avail -BG "$disk_dir" 2>/dev/null | tail -n 1 | tr -dc '0-9')"
[ "${free_gb:-0}" -ge "$min_free_gb" ] || [ "$DRY_RUN" = "1" ] || die "less than ${min_free_gb} GB free in $INSTALL_DIR"
if ! find "$BACKUP_DIR" -name "db-$profile-*.age" -mmin -1440 2>/dev/null | grep -q .; then
  log "no backup newer than 24 hours: running backup-now.sh"
  backup_args=(--profile "$profile")
  [ "$DRY_RUN" = "1" ] && backup_args+=(--dry-run)
  run "$DEPLOY_DIR/scripts/backup-now.sh" "${backup_args[@]}"
fi

# 2. Verify the bundle, load images, compare image ids with the manifest
( cd "$BUNDLE_DIR" && run sha256sum --check --strict SHA256SUMS )
if [ "$DRY_RUN" != "1" ]; then
  [ "$(jq -r .version "$BUNDLE_DIR/release-manifest.json")" = "$version" ] || die "bundle manifest is for another version"
fi
run docker load --input "$BUNDLE_DIR/images.tar"
if [ "$DRY_RUN" != "1" ]; then
  for name in api web migrate; do
    want="$(jq -r ".images.$name.id" "$BUNDLE_DIR/release-manifest.json")"
    got="$(docker image inspect --format '{{.Id}}' "bappelitbangda-$name:$version")"
    [ "$want" = "$got" ] || die "image id mismatch for $name (manifest $want, loaded $got)"
  done
  log "image ids match the manifest"
fi

previous="$(read_state "$profile" current)"
rollback() {
  log "FAILED. Returning to the previous version: ${previous:-none}"
  if [ -n "$previous" ]; then
    VERSION="$previous" compose "$profile" up -d || true
    log_deploy "$version" "$profile" "failed, restored $previous"
  else
    log_deploy "$version" "$profile" "failed, no previous version"
  fi
  exit 1
}

# 3. Migrations (expand and contract: the new schema works with the old and the new application version)
run compose "$profile" up -d --wait "db$suffix"
run compose "$profile" run --rm "migrate$suffix" up || rollback

# 4. Start the new application version (database and nginx are unchanged unless the release says so)
run compose "$profile" up -d || rollback

# 5. Health check and smoke test
smoke_with_retry "$smoke_url" || rollback

# 6. Record the release; keep only the last two versions' images
[ -z "$previous" ] || write_state "$profile" previous "$previous"
write_state "$profile" current "$version"
if [ "$DRY_RUN" != "1" ]; then
  keep=" $version ${previous:-} "
  while read -r ref; do
    tag="${ref##*:}"
    case "$keep" in *" $tag "*) ;; *) docker rmi "$ref" >/dev/null 2>&1 || true ;; esac
  done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep -E '^bappelitbangda-(api|web|migrate):v' || true)
fi
log_deploy "$version" "$profile" ok
log "done"

#!/usr/bin/env bash
# UNTESTED ON THE VPS: run on staging first.
# Shared helpers for the deploy scripts. Source it; do not run it.
# shellcheck shell=bash

INSTALL_DIR="${INSTALL_DIR:-/opt/bappelitbangda}"
BACKUP_DIR="${BACKUP_DIR:-$INSTALL_DIR/backups}"
DRY_RUN="${DRY_RUN:-0}"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# run <command...>: print the command; execute it unless --dry-run.
run() {
  if [ "$DRY_RUN" = "1" ]; then printf '[dry-run] %s\n' "$*"; return 0; fi
  log "+ $*"
  "$@"
}

# Compose services by profile: prod = db api web nginx; staging = db-staging api-staging ...
profile_suffix() { case "$1" in prod) echo "" ;; staging) echo "-staging" ;; *) die "profile must be staging or prod" ;; esac; }

compose() { # compose <profile> <args...>
  local profile="$1"; shift
  VERSION="${VERSION:?VERSION not set}" docker compose -f "$DEPLOY_DIR/docker-compose.yml" --profile "$profile" "$@"
}

state_file() { echo "$INSTALL_DIR/state/$1.$2"; } # state_file <profile> current|previous

read_state() { local f; f="$(state_file "$1" "$2")"; [ -f "$f" ] && cat "$f" || true; }

write_state() { # write_state <profile> <kind> <version>
  [ "$DRY_RUN" = "1" ] && { printf '[dry-run] write %s = %s\n' "$(state_file "$1" "$2")" "$3"; return 0; }
  mkdir -p "$INSTALL_DIR/state"; printf '%s\n' "$3" > "$(state_file "$1" "$2")"
}

# Append an entry for docs/handover/deploy-log.md (the VPS has no git: a human commits it).
log_deploy() { # log_deploy <version> <profile> <result>
  local line
  line="| $(date +%F) | ${DEPLOYER:-$(id -un)} | $1 | $2 | $3 |"
  if [ "$DRY_RUN" = "1" ]; then echo "[dry-run] deploy-log entry (not written): $line"; return 0; fi
  echo "deploy-log entry (add to docs/handover/deploy-log.md): $line"
  mkdir -p "$INSTALL_DIR"; echo "$line" >> "$INSTALL_DIR/deploy-log.md"
}

# smoke_with_retry <url>: the stack needs a few seconds after `compose up`; retry for up to 60 seconds.
smoke_with_retry() {
  local url="$1" n
  if [ "$DRY_RUN" = "1" ]; then echo "[dry-run] $DEPLOY_DIR/scripts/smoke.sh $url   (retried for up to 60 seconds)"; return 0; fi
  for n in $(seq 1 12); do
    if "$DEPLOY_DIR/scripts/smoke.sh" "$url"; then return 0; fi
    log "smoke test not passing yet (attempt $n of 12)"; sleep 5
  done
  return 1
}

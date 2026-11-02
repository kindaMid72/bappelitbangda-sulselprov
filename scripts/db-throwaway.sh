#!/usr/bin/env bash
# Runs a command against a freshly migrated, throwaway PostgreSQL database, then drops it.
#   scripts/db-throwaway.sh <command> [args...]
# The command sees TEST_DB_NAME and TEST_DATABASE_URL (superuser URL of the throwaway database).
# Environment (set by the Makefile):
#   PSQL          psql command that connects as a superuser (local: via docker compose; CI: plain psql)
#   PG_SUPER_URL  superuser URL without database, for example postgres://postgres:postgres@localhost:5432
#   GOOSE         command that runs goose from api/ with the tools module
set -euo pipefail
: "${PSQL:?}" "${PG_SUPER_URL:?}" "${GOOSE:?}"
[ $# -gt 0 ] || { echo "usage: $0 <command> [args...]" >&2; exit 2; }

name="bappelitbangda_tmp_$$_$(date +%s)"
cleanup() {
  # shellcheck disable=SC2086  # PSQL is a command line with arguments
  $PSQL -d postgres -c "DROP DATABASE IF EXISTS ${name} WITH (FORCE)" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# shellcheck disable=SC2086
$PSQL -d postgres -c "CREATE DATABASE ${name}" >/dev/null
export TEST_DB_NAME="$name"
export TEST_DATABASE_URL="${PG_SUPER_URL}/${name}?sslmode=disable"
# shellcheck disable=SC2086
$GOOSE -dir db/migrations postgres "$TEST_DATABASE_URL" up >/dev/null
"$@"

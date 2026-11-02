#!/usr/bin/env bash
# Runs every api/db/tests/*.sql against the throwaway database named in TEST_DB_NAME.
# Called through scripts/db-throwaway.sh (which creates, migrates and drops the database). Run from api/.
set -euo pipefail
: "${PSQL:?}" "${TEST_DB_NAME:?}"
status=0
for f in db/tests/*.sql; do
  # shellcheck disable=SC2086  # PSQL is a command line with arguments
  if $PSQL -d "$TEST_DB_NAME" < "$f" >/dev/null; then echo "db-test: ok   $f"; else echo "db-test: FAIL $f"; status=1; fi
done
exit "$status"

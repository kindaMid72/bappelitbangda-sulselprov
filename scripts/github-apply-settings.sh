#!/usr/bin/env bash
# Applies the repository settings from docs/workflow/team-and-agents.md sections 11-12 with the GitHub CLI.
# Default is DRY-RUN: it only prints the commands. Nothing changes without --apply.
#
# Usage: scripts/github-apply-settings.sh OWNER/REPO [--apply] [--approvals N] [--no-main-ruleset]
#   --approvals N   required approving reviews on main (default 1). Use 0 while only one GitHub
#                   account can review; raise to 1 (with code owner review) when the second developer joins.
#   --no-main-ruleset  skip the branch ruleset for main. Use it while the CI workflows are not yet on main:
#                   a required status check that never reports would block every merge.
set -euo pipefail

usage() { echo "Usage: $0 OWNER/REPO [--apply] [--approvals N] [--no-main-ruleset]" >&2; exit 2; }

repo="${1:-}"; [ -n "$repo" ] || usage
shift
apply=0
approvals=1
main_ruleset=1
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) apply=1 ;;
    --approvals) shift; approvals="${1:-}" ;;
    --no-main-ruleset) main_ruleset=0 ;;
    *) usage ;;
  esac
  shift
done
[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || usage
[[ "$approvals" =~ ^[0-9]+$ ]] || usage

root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

# step "description" <command...>   (dry-run prints; apply runs and tolerates plan-limit failures)
step() {
  local desc="$1"; shift
  if [ "$apply" -eq 0 ]; then
    printf '[dry-run] %s\n          %s\n' "$desc" "$*"
    return 0
  fi
  printf '[apply]   %s ... ' "$desc"
  # shellcheck disable=SC2001  # sed is clearer than ${var//} for a per-line prefix
  if out="$("$@" 2>&1)"; then echo "ok"; else echo "FAILED"; echo "$out" | sed 's/^/          /'; failures=$((failures + 1)); fi
}

# Ruleset JSON with the review requirement adjusted for --approvals.
main_ruleset_json() {
  jq --argjson n "$approvals" '
    (.rules[] | select(.type == "pull_request") | .parameters) |=
      (.required_approving_review_count = $n
       | if $n == 0 then .require_code_owner_review = false | .require_last_push_approval = false else . end)
  ' "$root/.github/rulesets/main.json"
}

upsert_ruleset() {
  local name="$1" json="$2" id
  id="$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$name\") | .id" 2>/dev/null || true)"
  if [ -n "$id" ]; then
    printf '%s' "$json" | gh api -X PUT "repos/$repo/rulesets/$id" --input - >/dev/null
  else
    printf '%s' "$json" | gh api -X POST "repos/$repo/rulesets" --input - >/dev/null
  fi
}

echo "Target: $repo   mode: $([ "$apply" -eq 1 ] && echo APPLY || echo dry-run)   approvals on main: $approvals"
[ "$apply" -eq 1 ] || echo "(nothing is changed; re-run with --apply after reviewing this plan)"
echo

step "Merge settings: squash only, delete head branches, no auto-merge, no wiki/projects/discussions" \
  gh api -X PATCH "repos/$repo" \
    -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
    -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
    -F delete_branch_on_merge=true -F allow_auto_merge=false -F allow_update_branch=true \
    -F has_issues=true -F has_wiki=false -F has_projects=false -F has_discussions=false

step "Actions: default GITHUB_TOKEN read-only, workflows cannot approve PRs" \
  gh api -X PUT "repos/$repo/actions/permissions/workflow" \
    -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false

step "Actions: only GitHub-owned actions are allowed" \
  gh api -X PUT "repos/$repo/actions/permissions" -F enabled=true -f allowed_actions=selected
step "Actions allow-list: GitHub-owned only, no third-party patterns" \
  gh api -X PUT "repos/$repo/actions/permissions/selected-actions" \
    -F github_owned_allowed=true -F verified_allowed=false
step "Actions: require approval to run workflows from all external contributors" \
  gh api -X PUT "repos/$repo/actions/permissions/fork-pr-contributor-approval" -f approval_policy=all_external_contributors

step "Dependabot alerts on" gh api -X PUT "repos/$repo/vulnerability-alerts"
step "Dependabot security updates on" gh api -X PUT "repos/$repo/automated-security-fixes"
step "Secret scanning and push protection on (public repo or paid plan)" \
  gh api -X PATCH "repos/$repo" \
    -f 'security_and_analysis[secret_scanning][status]=enabled' \
    -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
step "Private vulnerability reporting on" gh api -X PUT "repos/$repo/private-vulnerability-reporting"

if [ "$main_ruleset" -eq 1 ]; then
  step "Ruleset: main-protection (approvals=$approvals)" upsert_ruleset main-protection "$(main_ruleset_json)"
else
  echo "[skip]    Ruleset: main-protection (--no-main-ruleset)"
fi
step "Ruleset: release-tags-immutable" upsert_ruleset release-tags-immutable "$(cat "$root/.github/rulesets/tags.json")"

echo
if [ "$apply" -eq 1 ]; then
  echo "Done with $failures failed step(s). Failures usually mean a plan limit; record missing controls in docs/handover/OWNERS.md."
  echo "Remember: add the real status-check names to .github/rulesets/main.json after the first CI run."
  [ "$failures" -eq 0 ] || exit 1
else
  echo "Dry-run finished. Nothing was changed."
fi

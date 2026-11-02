# Team and agent workflow

How the two of us work in this repo, with and without AI coding agents. Agent rules live in `AGENTS.md`; this file holds only what people need beyond them. Commands: `make` (see `AGENTS.md`). CI: `.github/workflows/`. Branch protection: `.github/rulesets/`. Release and deploy: `docs/handover/runbook.md`.

## Principles

1. **Review attention is the bottleneck, not code generation.** Cap: 2 open PRs per author.
2. **Contract first.** `openapi.yaml` and the migrations are the fence; CI proves nothing drifted.
3. **`make verify-full` is the definition of done.** CI is the gate; prompts and rules files are reminders. A rule that must never break belongs in CI or a deny rule.
4. **The security lane is never delegated.** Auth, sessions, KTP encryption and key handling are read line by line by the person who did not write them.
5. **One source of truth per fact.** Link, do not copy.
6. **Built for handover.** Diskominfo staff who did not write the code must be able to run, patch and restore it.

## Roles

| Area | Writes | Reviews before merge |
|---|---|---|
| `api/` (handlers, queries, migrations) | BE | FE |
| `web/` | FE | BE |
| `openapi.yaml` | whoever holds the open contract task | the other, same day |
| Auth, sessions, RBAC, TOTP, KTP encryption, keys | BE drafts | both read every line |
| Makefile, CI, `AGENTS.md`, `.claude/`, handover docs | shared, by PR | the other |

`CODEOWNERS` lists every developer on `*`, so the other person is always the required reviewer. It has one handle today; add the second developer's handle on the same line when they join, then raise required approvals to 1 (`scripts/github-apply-settings.sh --approvals 1`).

## Data and secrets

- Agents work against a local dev database with synthetic data. No production credentials, real KTP numbers, real `.env` or VPS access in any agent session.
- `.env` is git-ignored; `.env.example` holds fake values. Production `.env`, the database password and the KEK live only on the VPS; the KEK is held by two named people, one a Diskominfo officer, and is never in the repo or in backups. Roles are in `docs/handover/OWNERS.md`.
- If a secret is ever committed or pasted into an agent session, treat it as leaked: rotate first, clean up after.
- Deny rules reduce accidents but are not a security boundary for shell commands; use a dev container or the sandbox where possible.
- Whether source code may go to an external AI service is an open question for Diskominfo (see `docs/handover/known-gaps.md`). Until answered, no real data reaches an agent.

## Task loop

1. **Issue** from the task template. For anything touching schema or auth, the human writes a short SPEC in the issue.
2. **Contract PR first**, if the API changes: edit `openapi.yaml` only, `make gen`, commit the regenerated files, open a small PR. The other person reviews the same day. After it merges, BE implements the handlers and queries while FE builds against a Prism mock, then Prism proxy, then the real server.
3. **Branch** as described below.
4. **Plan, then implement.** Read the agent's plan before it writes code; implement in a fresh session.
5. **Verify** with `make verify` until it exits 0. Read edited tests for weakened assertions.
6. **PR**: one task, small, from the template. The author explains the diff, including "what I do not yet understand about this diff".
7. **Review** by the other person. A second fresh agent session as reviewer is optional and never replaces the human.
8. **Merge** by a human, squash only, one branch at a time. CI reruns on `main`. Remove the branch and worktree.

## Branches and parallel work

1. Every branch starts from an issue. Name: `<type>/<issue-id>-<slug>`, type one of `feat|fix|chore|docs`. No issue, no branch: open a one-line issue.
2. Create from fresh `main`: `git fetch origin && git switch -c <branch> origin/main`. If a second session runs at the same time, use a worktree instead: `git worktree add ../wt/<issue-id> -b <branch> origin/main`. A worktree isolates files only, so run the dev stack (ports, dev database) from one checkout at a time. `make verify` and `make db-test` use throwaway databases and are safe in parallel.
3. One task, one branch, one PR, one worktree. When the PR merges: `git worktree remove` and `git branch -d`.
4. The PR title becomes the squash commit and the release note, so it must name the change. The PR body has `Closes #<issue-id>`. Contract, migration and feature changes go in separate PRs.
5. Claim work by assigning the issue to yourself before branching. An assigned issue is a lock.
6. Limits: 2 open PRs per author, one open contract PR, one open migration PR (two parallel migrations collide on ordering).
7. Avoid stacked PRs. Contract first already lets BE and FE work in parallel. If a stack is unavoidable, keep it to depth 2, never merge branches into each other, and after the parent is squash-merged run `git rebase --onto main <parent>` on the child. Agents never force-push.

Traceability chain: PRD id, issue, branch name, PR (`Closes #n`), squash commit on `main`, release note.

## Contract and database

Rules are in `AGENTS.md` and `.claude/rules/api.md`. Also: breaking API changes (renamed field, changed status code) need a note in the PR and the FE reviewer's approval; risky schema changes use expand and contract across two releases; only one contract PR is open at a time.

## Security lane checklist (the PR template ticks these)

- An agent may draft; the author explains every line and the other person reads every line.
- Design is fixed by PRD Appendix D: `scs` + `pgxstore` sessions, argon2id with at most 2 concurrent hashes (re-check OWASP parameters), `Can(user, perm)` deny by default, progressive delay per account and IP and never a permanent lock (FR-33), TOTP for Super Admin and Petugas PPID, KTP step-up and audit, KEK outside repo and backups, key id inside the ciphertext.
- Encryption uses stdlib AES-GCM with envelope encryption. No custom crypto; nonce and key handling are never left to an agent unreviewed.
- Tests exercise the real auth path plus negative authorization cases; no test-only bypass.
- Before go-live: OWASP ASVS level 2 for the admin panel, authentication and the PPID module (NFR-05), level 1 elsewhere; `govulncheck` clean; an independent review or a network-restricted admin panel.

## Repository settings (a human applies them; agents never change settings)

`.github/rulesets/main.json` and `scripts/github-apply-settings.sh` (dry run first, then `--apply`) are the source of truth for branch and tag protection and merge methods. Beyond them:

- Own the repository through an organization with at least two owners and required two-factor authentication. The repository is currently public under a personal account (see `docs/decisions/prd-v1.1-reconciliation.md` item 6). Move it to an organization or a Diskominfo Git host before handover.
- No outside collaborators with write access. No forking of private repositories. Wiki, Projects and Discussions off.
- Actions: read-only default token, third-party actions pinned by full commit SHA, "allow Actions to create and approve pull requests" off, no secrets other than `GITHUB_TOKEN`, no webhooks or integrations unless added in a PR that says why.
- Secret scanning with push protection if the plan offers it; otherwise `gitleaks` (already in `make`).
- Once a week a maintainer runs `git clone --mirror` to a location Diskominfo or the VPS owner controls, so the code does not live only in one organization.
- With two organization owners, an owner can still edit the rules. The ruleset prevents accidents and unreviewed pushes, not a deliberate owner. An emergency fix uses the same path (PR, green CI, review); if a rule truly blocks it, change the rule deliberately, note it in `docs/handover/deploy-log.md`, and restore it right after.
- If the host or plan cannot enforce a control, write it in `docs/handover/OWNERS.md` and enforce what is possible elsewhere.
- A red `main` is the top priority. A flaky test is fixed or quarantined with an issue within a day.

## Rhythm

- Daily, 10 minutes: who holds the contract today, open tasks, blockers.
- Friday, 30 minutes: explain-back. Each of us walks the other through a module they did not write. This is how we avoid code nobody understands at handover. Update the runbook and `known-gaps.md`.
- Weekly: close stale branches and worktrees. Once a week, write one small core piece by hand.

## Handover checklist

- One-command local run; READMEs accurate; a Diskominfo staff member cold-starts it from the README on a clean machine (NFR-14).
- Runbook complete: deploy, rollback, backup and restore, key rotation, add an admin, TOTP break-glass.
- Restore drill done by Diskominfo staff, including decrypting a test KTP with the key.
- Dependencies are explained by `api/go.mod`, `web/package.json` and the SBOM; add the reason in the PR that adds each one.
- `docs/handover/OWNERS.md` names the system owner and the patch owners (application, OS/VPS).
- Known gaps listed honestly.

Status: draft
Last reviewed: 2026-11-02

# PRD v1.1 reconciliation

Report only. Nothing in the other documents was rewritten. The PRD wins for requirements; the PRD does not govern workflow choices.
Compared on 2026-11-02: `docs/prd/PRD.md` against `docs/workflow/team-and-agents.md` and `docs/workflow/SETUP-AGENT-WORKFLOW.md`.
The TDD, `tech-stack.md`, `audit-tdd-vs-prd.md` and `tooling.md` were **not supplied**, so they could not be compared (placeholders exist).

## A. Mismatches between the PRD and the other documents

| # | Document | Location | Says | PRD says | Proposed fix | Owner |
|---|---|---|---|---|---|---|
| 1 | PRD / workflow | PRD Appendix D vs workflow sections 14, 16, 21 and setup Phase 7 | Workflow and setup assume a TDD with one file per ADR (ADR-14, D5, D6) | "There is no separate technical design document"; hard-to-reverse decisions are rows in Appendix D, plus a 1-2 page spec per module | Decide one: either keep the TDD/ADR files as the detail behind Appendix D, or drop `docs/tdd/` and use per-module specs. Until then `docs/tdd/TDD.md` is a placeholder | both developers |
| 2 | workflow | section 17, security lane | "lockout per account and IP" | FR-33: repeated failures are throttled with a progressively longer delay, **without locking the account permanently** (5 failures: 15-minute delay, configurable) | Reword to "progressive delay per account and IP"; make sure the design does not permanently lock an account | BE, reviewed by FE |
| 3 | workflow | sections 5 and 13 (`make test`, CI) | No coverage gate | NFR-14 (Should): automated coverage of 60% or more on business logic; 100% of API endpoints documented; new developer runs the system from the README in 30 minutes | Add a coverage threshold on business-logic packages to `make test` once there is business logic; add a README cold-start test to the handover checklist | both |
| 4 | workflow | section 14 (deploy compose, release) | No antivirus scanner in the deploy design | NFR-06: files from public forms are scanned by antivirus before officers can open them (scanner availability depends on OQ-04) | Add a scanner service (for example ClamAV) to `deploy/docker-compose.yml` or record the missing control in `docs/handover/known-gaps.md`; EICAR test in `make smoke` | BE |
| 5 | workflow | section 14 (backup) | Backup mentioned only as "restic backup set" and `backup-now.sh` | NFR-10 / NFR-17 / Appendix D: daily **encrypted** backup to a location **outside the application server** where available; restore test including key recovery before MVP release | State the off-server target and encryption in the runbook; the restore drill must include decrypting a test KTP with the key | BE with Diskominfo |
| 6 | workflow | section 4 ("Open question ... Until answered, code stays private") and section 11 (private repo, decision D6) | Code stays private until Diskominfo answers whether sending source code to an AI service is allowed | PRD is silent on repository visibility | **Deviation taken on 2026-11-02:** the repository is public under a personal account. Get Diskominfo's written decision on both points (public code, AI service use). Real data and secrets are never in the repo | both, Diskominfo |
| 7 | setup recipe | section 00, "PRD v1.1 (Indonesian)" and "Do not translate" | The supplied PRD copy is expected to be Indonesian | `PRD-v1.1.md` is the English 1:1 translation; the Indonesian Google Doc is the master | Keep the copy as supplied (header states it). Note it in `docs/prd/README.md` (done) | both |
| 8 | setup recipe | Phase 4 / Phase 1 | Assumes `db-*` targets, `api/`, `web/` and a Makefile already exist | The repository was empty | Created as part of the bootstrap (walking skeleton); recorded as a deviation in the setup report | both |
| 9 | setup recipe | Phase 4 `tools` target | `go install ...@TODO_PIN` with stale pins (goose 3.24.1, sqlc 1.28.0) | NFR-14 (reproducible build, CI green) | Pin through the Go `tool` directive in `api/go.mod` (checksum-verified, Dependabot-updatable) | BE |
| 10 | workflow | section 12 (required approvals 1, code owner) | 1 approval from the other developer | C-5: team of 2 | Only one GitHub account exists today, so the ruleset starts with 0 required approvals and is raised to 1 when the second developer is added (`scripts/github-apply-settings.sh --approvals 1`) | both |
| 11 | workflow | section 22 (week 1) | "SvelteKit 3 vs 2 spike" | Appendix D: SvelteKit | SvelteKit 2 (stable) chosen at bootstrap; SvelteKit 3 was still alpha/next in the research done on 2026-11-02. Revisit after it is stable | FE |

## B. Open points inside the PRD that need a human decision

| # | PRD location | Question | Owner |
|---|---|---|---|
| 12 | FR-24 vs FR-37 vs section 3.4 | Who enters holiday data for working-day calculation? FR-24 says holidays are "entered by the Super Admin"; FR-37 says the Humas Editor and Super Admin manage holidays; the PPID Officer owns the deadlines but has no holiday rights in the matrix. | Bappelitbangda, PPID |
| 13 | OQ-12 / NFR-06 | Upload types and sizes (including `.zip` / `.rar`) are undecided, so nginx upload limits and the antivirus scope are left as TODO. | Diskominfo, PPID |
| 14 | OQ-14 | Committed scope (MVP only, or MVP plus Phase 2) decides how much of Phase 2 is planned; the traceability table lists all phases. | Bappelitbangda, Diskominfo, developers |

## C. New external information (not in the PRD)

- Government Regulation No. 33 of 2026 (PP 33/2026) implements the Personal Data Protection Law (UU PDP, Law 27 of 2022). Secondary sources (law-firm client alerts, Aug-Sep 2026) say it was issued on 16 July 2026 and takes effect on **16 January 2027**, close to the end of the internship period. It may affect NFR-08 and OQ-15 (retention, data subject requests, breach notification). Verify the text with PPID or legal counsel before relying on it.

## D. Checked and consistent

- ASVS: workflow section 17 already uses level 2 for the admin panel, authentication and the PPID module, as in NFR-05 and Appendix D. No "ASVS L1" for those modules and no "16 NFR" wording was found in the supplied workflow documents.
- Two key holders, key outside repo and backups, AEAD with key id in the ciphertext (workflow sections 15 and 17) match NFR-17 and OQ-17.
- RTO 4 hours (workflow section 14) matches NFR-10.
- Counts: 45 FR (28 Must, 12 Should, 4 Could, 1 Won't) and 17 NFR (12 Must, 5 Should) were recomputed from `docs/prd/PRD.md` by `scripts/gen-traceability.sh`.

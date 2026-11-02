# PRD v1.1 reconciliation (open items only)

The PRD wins for requirements; it does not govern workflow choices. Item numbers are kept from the first version (2026-11-02) so references stay valid; resolved items were deleted. Gaps already tracked in `docs/handover/known-gaps.md` (antivirus NFR-06, off-server backup NFR-10/17, upload limits OQ-12) are not repeated here.

## A. Mismatches that need a decision

| # | Where | Says | PRD says | Proposed fix | Owner |
|---|---|---|---|---|---|
| 1 | PRD Appendix D vs the earlier workflow draft | A TDD with one file per ADR | "There is no separate technical design document"; hard-to-reverse decisions are rows in Appendix D, plus a 1-2 page spec per module | Proposed: follow the PRD. Appendix D is the decision log, there is no `docs/tdd/`, and detail goes in per-module specs. Needs both developers to confirm | both developers |
| 3 | `make test` / CI | No coverage gate | NFR-14 (Should): 60% or more automated coverage of business logic; every API endpoint documented; a new developer runs the system from the README in 30 minutes | Add a coverage threshold on business-logic packages once there is business logic; the README cold-start is in the handover checklist | both |
| 6 | Repository visibility | Earlier draft: private organization, code private until Diskominfo answers | PRD is silent on visibility | **Deviation taken on 2026-11-02:** the repository is public under a personal account. Get Diskominfo's written decision on public code and on AI-service use. Real data and secrets are never in the repo | both, Diskominfo |

## B. Open points inside the PRD

| # | PRD location | Question | Owner |
|---|---|---|---|
| 12 | FR-24 vs FR-37 vs section 3.4 | Who enters holiday data for working-day calculation? FR-24 says the Super Admin; FR-37 says the Humas Editor and Super Admin; the PPID Officer owns the deadlines but has no holiday rights in the matrix. | Bappelitbangda, PPID |
| 14 | OQ-14 | Committed scope (MVP only, or MVP plus Phase 2) decides how much of Phase 2 is planned; the traceability table lists all phases. | Bappelitbangda, Diskominfo, developers |

## C. New external information (not in the PRD)

Government Regulation No. 33 of 2026 (PP 33/2026) implements the Personal Data Protection Law (UU PDP, Law 27 of 2022). Secondary sources (law-firm client alerts, Aug-Sep 2026) say it was issued on 16 July 2026 and takes effect on 16 January 2027, close to the end of the internship. It may affect NFR-08 and OQ-15 (retention, data subject requests, breach notification). Verify the text with PPID or legal counsel before relying on it.

## E. Deploy tooling: deviations from the first workflow draft

- `docker build` smoke runs on every CI run, not only on `main`, so a broken Dockerfile is caught in the PR.
- `release.yml` adds a build provenance attestation (`actions/attest`, public repository) and disables dependency caches in that job (zizmor `cache-poisoning`).
- A one-shot `migrate` image (goose plus the release's migrations) runs as a compose job per profile, because the database port is not published.
- Backups are encrypted with `age` to a public recipient key (private key off the server). The PRD names no standard; this is a placeholder for OQ-16 / OQ-17.
- Tested locally only (Docker on a developer laptop, synthetic data): bundle build, `deploy.sh` dry run and real run, checksum failure on a modified bundle, image-id check, migration job, two successive deploys, `rollback.sh`, automatic return after a failed smoke test, admin allowlist (403). Not tested: the real VPS, TLS, the systemd fallback, real `age` backups, `gh attestation verify`.

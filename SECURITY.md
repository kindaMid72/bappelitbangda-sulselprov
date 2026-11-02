# Security policy

This repository is public. It must never contain secrets, encryption keys, real personal data (for example KTP numbers) or production configuration.

## Reporting a vulnerability

Please do **not** open a public issue. Use GitHub's private vulnerability reporting:
Security tab of this repository, then "Report a vulnerability".

Include what you found, where, and the steps to reproduce it. Do not access, copy or change data that is not yours.

## If a secret is committed

Treat it as leaked: rotate it first, then clean up the history. Rotation steps will be in `docs/handover/runbook.md`.

Status: draft
Last reviewed: 2026-11-02

# Runbook

## Deploy
UNTESTED ON THE VPS: run on staging first. GitHub builds and proves the release; a maintainer deploys by hand.
1. Download the bundle on your own laptop: `gh release download vX.Y.Z` (your own login; the VPS holds no GitHub credentials). Verify provenance with `gh attestation verify deploy-bundle-vX.Y.Z.tar.gz --repo <owner>/<repo>`.
2. Copy it to the server (`scp`), extract it, and run `deploy/scripts/deploy.sh vX.Y.Z --profile staging` (add `--dry-run` first).
3. After the staging smoke test passes and the production checklist in `docs/workflow/team-and-agents.md` section 14 is done, repeat with `--profile prod`.
`deploy.sh` checks free disk space and a backup newer than 24 hours, verifies `SHA256SUMS`, loads the images, compares image ids with the manifest, runs migrations, starts the stack, runs the smoke test, returns to the previous version on failure, and prints a line for `deploy-log.md`.
Environment files (`.env.production`, `.env.staging`, mode 0600) and the KEK file live in `/opt/bappelitbangda` (see `deploy/env.example`); they are never in a bundle.

## Rollback
`deploy/scripts/rollback.sh --profile staging|prod` redeploys the previous version (its images are kept). Migrations are not rolled back: if the last migration was not backward compatible, restore from backup (target recovery time 4 hours, NFR-10).

## Backup and restore
`deploy/scripts/backup-now.sh --profile prod` writes an `age`-encrypted `pg_dump` to `/opt/bappelitbangda/backups`. It needs `BACKUP_AGE_RECIPIENT` (public key; the private key is held off the server, OQ-17) and refuses to write an unencrypted file. Copying backups off the server is not automated yet (known gap; target depends on OQ-04). Restore steps: TODO, written during the first restore drill (`restore-drill.md`).

## Key rotation
TODO

## Add an admin
TODO

## TOTP break-glass
TODO

Note: this repository is public. Keep key custody details and break-glass secrets out of it; record only the procedure and where the private copy is kept.

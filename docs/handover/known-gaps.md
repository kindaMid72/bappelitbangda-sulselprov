Status: draft
Last reviewed: 2026-11-02

# Known gaps

- PRD v1.1 is not signed.
- TDD, tech-stack decisions, audit and database tooling docs are placeholders.
- Open questions that block design: OQ-01, 02, 03, 04, 11, 12, 13, 14, 15, 16, 17.
- Deploy tooling (`deploy/`, `scripts/release.sh`) is tested only on a local Docker host, never on the real VPS; the systemd fallback (no Docker) does not exist yet.
- nginx has no TLS, HSTS or CSP yet (certificate and standard depend on OQ-16); upload size limits wait for OQ-12.
- Backups are encrypted with `age`, but copying them off the server is manual; the encryption standard waits for OQ-16.
- SBOMs cover the Go module and the npm lockfile, not the container images.
- Antivirus scanning of public-form uploads (NFR-06) is not in the stack yet.

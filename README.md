# Bappelitbangda Sulsel web

Rebuild of the website of Bappelitbangda of South Sulawesi Province (public site, admin panel, PPID service forms).
Go backend in `api/`, SvelteKit frontend in `web/`, PostgreSQL, OpenAPI contract in `openapi.yaml`.

**Prerequisites:** Go (see `api/go.mod`), Node 24, Docker (for the local PostgreSQL), `make`.

**Quick start:** `make db-up db-init db-migrate`, then see `api/README.md` and `web/README.md`.

**Status:** work in progress. Requirements are in `docs/prd/`. The PRD is not signed yet.

Everything else (requirements, decisions, workflow, handover) is indexed in [`docs/README.md`](docs/README.md).

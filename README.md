# Bappelitbangda Sulsel web

Rebuild of the website of Bappelitbangda of South Sulawesi Province (public site, admin panel, PPID service forms).
Go backend in `api/`, SvelteKit frontend in `web/`, PostgreSQL, OpenAPI contract in `openapi.yaml`.

**Prerequisites:** Go 1.26+, Node 24, Docker (for the local PostgreSQL), `make`.

**Quick start:**

```sh
make db-up db-init db-migrate      # local PostgreSQL with synthetic data
cd web && npm ci && cd ..          # frontend dependencies
make verify                        # the gate: generation check, lint, tests, vulnerability scan
```

Run the API (`cd api && go run ./cmd/api`) and the web app (`cd web && npm run dev`); see `api/README.md` and `web/README.md`.

**Status:** work in progress. Requirements are in `docs/prd/`; the PRD is not signed yet.
This repository is public: never commit secrets or real personal data.

Everything else (requirements, decisions, workflow, handover) is indexed in [`docs/README.md`](docs/README.md).

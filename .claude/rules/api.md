---
paths:
  - "api/**"
---
# Go backend rules
- Handlers implement the generated strict-server interface (`api.StrictServerInterface`); never hand-edit generated code.
- Database access only through sqlc-generated queries in `api/db/queries/`.
- Authorization goes through `Can(user, perm)`, deny by default. No ad-hoc role checks.
- Sessions use scs + pgxstore. Passwords use argon2id with at most 2 concurrent hash operations.
- KTP numbers and TOTP secrets are ciphertext with a key id; never log them; never choose nonce or key handling yourself; draft only, a human explains every line.
- Return errors with context; no panics in handlers; no global state.
- Tests: table-driven; DB tests use the throwaway database from `make test-full` (`TEST_DATABASE_URL`) and skip under `testing.Short()`.

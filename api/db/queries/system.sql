-- name: Ping :one
-- Connectivity check used by tests and (later) the readiness probe.
SELECT 1::int AS ok;

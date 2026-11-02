-- Development and CI only. Idempotent. Run as a PostgreSQL superuser by `make db-init`.
-- Passwords here are fake development values; production roles and secrets live on the VPS only.
--   migrator: owns the database, runs goose migrations
--   app:      runtime role of the API; gets only the privileges migrations grant it
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'migrator') THEN
    CREATE ROLE migrator LOGIN PASSWORD 'migrator';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app') THEN
    CREATE ROLE app LOGIN PASSWORD 'app';
  END IF;
END
$$;

SELECT 'CREATE DATABASE bappelitbangda_dev OWNER migrator'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bappelitbangda_dev')\gexec

-- One case per query in api/db/queries/. Keep in step with the sqlc queries.
-- Ping
DO $$
BEGIN
  ASSERT (SELECT 1::int AS ok) = 1, 'Ping must return 1';
END
$$;

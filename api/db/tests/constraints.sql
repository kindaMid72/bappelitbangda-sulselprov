-- Database rule tests: each rule gets a check that FAILS when the rule is broken.
-- Run by `make db-test` against a freshly migrated throwaway database (ON_ERROR_STOP).
DO $$
BEGIN
  ASSERT (SELECT count(*) FROM pg_extension WHERE extname IN ('pg_trgm', 'unaccent')) = 2,
    'extensions pg_trgm and unaccent must exist (PRD Appendix D: PostgreSQL text search)';
END
$$;

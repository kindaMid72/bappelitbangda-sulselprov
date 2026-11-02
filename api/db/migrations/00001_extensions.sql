-- +goose Up
-- Extensions for PostgreSQL full-text and fuzzy search (PRD Appendix D: no separate search engine;
-- FR-04, FR-16). Both are "trusted" extensions, so the owning role can create them.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- +goose Down
DROP EXTENSION IF EXISTS unaccent;
DROP EXTENSION IF EXISTS pg_trgm;

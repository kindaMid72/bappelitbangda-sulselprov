package db_test

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/kindaMid72/bappelitbangda-sulselprov/api/internal/db/dbgen"
)

// Needs a real PostgreSQL. `make test-full` provides a throwaway database through TEST_DATABASE_URL.
func TestPing(t *testing.T) {
	if testing.Short() {
		t.Skip("needs PostgreSQL; skipped under -short")
	}
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; run `make test-full`")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	got, err := dbgen.New(pool).Ping(ctx)
	if err != nil {
		t.Fatalf("Ping: %v", err)
	}
	if got != 1 {
		t.Fatalf("Ping = %d, want 1", got)
	}

	// The migration must have created the search extensions (PRD Appendix D).
	for _, ext := range []string{"pg_trgm", "unaccent"} {
		var n int
		if err := pool.QueryRow(ctx, "SELECT count(*) FROM pg_extension WHERE extname = $1", ext).Scan(&n); err != nil {
			t.Fatalf("query extension %s: %v", ext, err)
		}
		if n != 1 {
			t.Errorf("extension %s is missing", ext)
		}
	}
}

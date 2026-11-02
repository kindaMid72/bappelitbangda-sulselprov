# web

SvelteKit 3 (Svelte 5) frontend, built with `adapter-node`. Interface text is Indonesian.

## Run

```sh
npm ci            # dependencies (install scripts are disabled by .npmrc)
npm run dev       # http://localhost:5173, /api is proxied to the Go API on :8080
npm run build && node build    # production server (PORT, API_INTERNAL_URL)
```

## Environment

Declared and validated in `src/env.ts`.

| Variable           | Purpose                                               | Default                 |
| ------------------ | ----------------------------------------------------- | ----------------------- |
| `API_INTERNAL_URL` | where the web server reaches the Go API (server side) | `http://localhost:8080` |
| `PORT`             | adapter-node listen port                              | `3000`                  |

## Test and check

```sh
npm run test      # vitest
npm run check     # svelte-check
npm run lint      # prettier + eslint
```

`src/lib/api/schema.d.ts` is generated from `../openapi.yaml` by `make gen`; do not edit it.

Design and decisions: see ../docs/

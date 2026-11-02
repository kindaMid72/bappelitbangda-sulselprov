import { defineEnvVars } from '@sveltejs/kit/env';

// Environment variables of the web app (SvelteKit 3: typed and validated at startup).
export const variables = defineEnvVars({
	API_INTERNAL_URL: {
		description: 'Base URL the web server uses to reach the Go API (server-side only).',
		schema: (value) => value || 'http://localhost:8080'
	}
});

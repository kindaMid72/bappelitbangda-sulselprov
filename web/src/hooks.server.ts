import { API_INTERNAL_URL } from '$app/env/private';
import type { Handle, HandleFetch } from '@sveltejs/kit/hooks';

// openapi-fetch reads these response headers inside `load`; SvelteKit only exposes allow-listed ones.
const SERIALIZED_HEADERS = new Set(['content-type', 'content-length']);

export const handle: Handle = ({ event, resolve }) =>
	resolve(event, { filterSerializedResponseHeaders: (name) => SERIALIZED_HEADERS.has(name) });

/** Server-side calls to the page's own /api/ go straight to the Go API instead of looping back. */
export const handleFetch: HandleFetch = async ({ event, request, fetch }) => {
	const url = new URL(request.url);
	if (url.origin === event.url.origin && url.pathname.startsWith('/api/')) {
		const target = new URL(url.pathname + url.search, API_INTERNAL_URL);
		return fetch(new Request(target, request));
	}
	return fetch(request);
};

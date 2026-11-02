import { createApiClient, getApiStatus } from '#lib/http/client.ts';
import type { PageLoad } from './$types';

// Universal load. The client always targets the page's own origin; on the server
// `handleFetch` (src/hooks.server.ts) forwards /api/ calls to the Go API.
// In the browser, nginx (production) or the Vite proxy (development) does the same.
export const load: PageLoad = async ({ fetch, url }) => {
	const apiStatus = await getApiStatus(createApiClient({ baseUrl: url.origin, fetch }));
	return { apiStatus };
};

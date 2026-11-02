import createClient from 'openapi-fetch';
import type { paths } from '../api/schema';

/** Typed API client. Types come from openapi.yaml through `make gen`; never write response types by hand. */
export function createApiClient(options: { baseUrl: string; fetch?: typeof fetch }) {
	return createClient<paths>(options);
}

export type ApiClient = ReturnType<typeof createApiClient>;

/** Returns 'ok' when the API answers its liveness check, otherwise 'down'. */
export async function getApiStatus(client: ApiClient): Promise<'ok' | 'down'> {
	try {
		const { data, response } = await client.GET('/api/v1/health');
		return response.ok && data?.status === 'ok' ? 'ok' : 'down';
	} catch {
		return 'down';
	}
}

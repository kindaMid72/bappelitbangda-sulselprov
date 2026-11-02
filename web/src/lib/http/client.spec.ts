import { describe, expect, it } from 'vitest';
import { createApiClient, getApiStatus } from './client';

function clientWith(handler: (req: Request) => Response | Promise<Response>) {
	return createApiClient({
		baseUrl: 'http://api.test',
		fetch: async (input) => handler(input as Request)
	});
}

describe('getApiStatus', () => {
	it('is ok when the API reports ok', async () => {
		const client = clientWith((req) => {
			expect(new URL(req.url).pathname).toBe('/api/v1/health');
			return Response.json({ status: 'ok' });
		});
		expect(await getApiStatus(client)).toBe('ok');
	});

	it('is down on a server error', async () => {
		const client = clientWith(() => new Response('boom', { status: 500 }));
		expect(await getApiStatus(client)).toBe('down');
	});

	it('is down when the network fails', async () => {
		const client = clientWith(() => {
			throw new TypeError('network');
		});
		expect(await getApiStatus(client)).toBe('down');
	});
});

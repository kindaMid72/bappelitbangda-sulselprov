<script lang="ts">
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>Bappelitbangda Sulawesi Selatan</title>
	<meta
		name="description"
		content="Situs web Bappelitbangda Provinsi Sulawesi Selatan (dalam pembangunan)."
	/>
</svelte:head>

<main>
	<h1>Bappelitbangda Sulawesi Selatan</h1>
	<p>Situs ini sedang dalam pembangunan.</p>
	<p>Status API: <strong>{data.apiStatus === 'ok' ? 'berjalan' : 'tidak tersedia'}</strong></p>
</main>

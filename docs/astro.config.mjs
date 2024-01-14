import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://qime.1sync.co',
	integrations: [
		starlight({
			title: 'QIME',
			social: {
				github: 'https://github.com/jawills/qime',
				youtube: 'https://www.youtube.com/channel/UCZvztpm28HOreQqX5nmOlYQ',
				linkedin: 'https://www.linkedin.com/in/justinwillsxyz/',
			},
			sidebar: [
				{
					label: 'Start Here',
					autogenerate: { directory: 'start-here' },

				},
				{
					label: 'Objects',
					autogenerate: { directory: 'objects' },
				},
			],
		}),
	],
});

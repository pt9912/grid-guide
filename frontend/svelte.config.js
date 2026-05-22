import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    // Static adapter (SPA-Modus) gemaess ADR 0002 §2:
    // - kein SSR, kein Node-Server zur Laufzeit,
    // - Tauri liefert die statischen Assets aus build/ direkt aus.
    adapter: adapter({
      pages: 'build',
      assets: 'build',
      fallback: 'index.html',
      precompress: false,
      strict: true
    })
  }
};

export default config;

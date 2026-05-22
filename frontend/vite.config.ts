import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

// Tauri-kompatible Vite-Einstellungen.
// Tauri-Dev-Server laeuft auf festem Port und ohne HMR-Overlay,
// damit Tauri 2.x den eingebetteten WebView ohne Reibung andocken
// kann. Siehe ADR 0003 und Tauri 2.x Vite-Integration.

const host = process.env.TAURI_DEV_HOST;

export default defineConfig({
  plugins: [sveltekit()],
  clearScreen: false,
  server: {
    port: 1420,
    strictPort: true,
    host: host ?? false,
    hmr: host
      ? {
          protocol: 'ws',
          host,
          port: 1421
        }
      : undefined,
    watch: {
      ignored: ['**/src-tauri/**']
    }
  },
  envPrefix: ['VITE_', 'TAURI_ENV_*']
});

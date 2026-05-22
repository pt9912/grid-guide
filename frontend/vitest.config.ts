import { defineConfig, mergeConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import viteConfig from './vite.config';

// Coverage-Schwellen gemaess Lastenheft GG-NFA-COV-001 (80 %
// Line-Coverage als MVP-Pflicht). Branch-Coverage (70 %) ist V1
// gemaess GG-NFA-COV-003 und wird hier dokumentiert, aber nicht
// gegated.
//
// Excludes folgen GG-NFA-COV-004 Teil 2 und bleiben eng gefasst:
// nur Konfig-/Test-Infrastruktur, kein Behavior-tragender Code.

export default mergeConfig(
  viteConfig,
  defineConfig({
    plugins: [svelte({ hot: false })],
    test: {
      environment: 'jsdom',
      globals: true,
      include: ['src/**/*.{test,spec}.{js,ts}'],
      setupFiles: ['./src/setup-tests.ts'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'lcov', 'html'],
        include: ['src/**/*.{js,ts,svelte}'],
        exclude: [
          'src/**/*.{test,spec}.{js,ts}',
          'src/setup-tests.ts',
          'src/app.d.ts'
        ],
        thresholds: {
          lines: 80,
          functions: 80,
          statements: 80
        }
      }
    }
  })
);

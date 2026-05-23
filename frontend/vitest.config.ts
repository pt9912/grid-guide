import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

// Coverage-Schwellen gemaess Lastenheft GG-NFA-COV-001 (80 %
// Line-Coverage als MVP-Pflicht). Branch-Coverage (70 %) ist V1
// gemaess GG-NFA-COV-003 und wird hier dokumentiert, aber nicht
// gegated.
//
// Excludes folgen GG-NFA-COV-004 Teil 2 und bleiben eng gefasst:
// nur Konfig-/Test-Infrastruktur, kein Behavior-tragender Code.
//
// Eigenstaendige Test-Config (NICHT via mergeConfig auf vite.config.ts
// aufsetzen): sveltekit() aus vite.config.ts registriert intern bereits
// vite-plugin-svelte; wenn wir hier dasselbe Plugin nochmal anbringen,
// kompiliert der zweite Pass die generierte Ausgabe des ersten Passes
// (z. B. props.svelte.js aus @testing-library/svelte-core mit
// `import * as $ from 'svelte/internal/client'`) erneut als Svelte-
// Source und scheitert am Runes-Namespace. Vitest braucht keine
// SvelteKit-Spezifika (Routing, $app), nur die Svelte-Komponenten-
// Transformation; svelte() alleine reicht.
//
// resolve.conditions priorisiert die "browser"-Condition, damit Svelte
// den Client-Build (index-client.js mit mount()) ausliefert und nicht
// den SSR-Build (index-server.js, ohne mount() — fuehrt zu
// `lifecycle_function_unavailable` in @testing-library/svelte/render).

export default defineConfig({
  plugins: [svelte({ hot: false })],
  resolve: {
    conditions: ['browser', 'module', 'import', 'default']
  },
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['src/**/*.{test,spec}.{js,ts}'],
    setupFiles: ['./src/setup-tests.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: ['src/**/*.{js,ts,svelte}'],
      // Excludes folgen GG-NFA-COV-004 Teil 2 (eng gefasst). Jeder
      // Eintrag ist mit einzeiliger Begruendung kommentiert.
      exclude: [
        // Test-Files sind per Definition kein Production-Code.
        'src/**/*.{test,spec}.{js,ts}',
        // Vitest-Setup laeuft nur im Test-Runner, nicht zur Laufzeit.
        'src/setup-tests.ts',
        // SvelteKit-Ambient-Type-Deklarationen ohne Laufzeitcode.
        'src/app.d.ts'
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        statements: 80
      }
    }
  }
});

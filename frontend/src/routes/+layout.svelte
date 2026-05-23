<script lang="ts">
  let { children } = $props();
</script>

<main>
  {@render children()}
</main>

<style>
  :global(html, body) {
    margin: 0;
    padding: 0;
    font-family:
      system-ui,
      -apple-system,
      'Segoe UI',
      sans-serif;
    background: #f5f5f7;
    color: #1d1d1f;
  }

  :global(*:focus-visible) {
    outline: 3px solid #0066cc;
    outline-offset: 2px;
    border-radius: 4px;
  }

  main {
    max-width: 640px;
    margin: 0 auto;
    padding: 2rem 1rem;
  }
</style>

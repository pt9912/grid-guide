<script lang="ts">
  // M1-Welle-2-Skelett: Hello-Seite mit Tastaturfokus-Demo.
  // Wirklicher Use-Case-UI (Projektuebersicht, Profilauswahl,
  // Review, Export) folgt in M6. Hier nur die Vorbereitung fuer
  // GG-NFA-A11Y-001-MVP (Tastaturbedienbarkeit) sichtbar machen.

  import { invoke } from '@tauri-apps/api/core';

  let name = $state('');
  let greeting = $state('');
  let error = $state('');

  async function onGreet() {
    error = '';
    try {
      // Tauri-Command 'greet' wird in src-tauri/src/main.rs
      // registriert. Wenn die Seite ohne Tauri-Host laeuft (z. B.
      // im Browser-Dev-Server ohne Tauri), faellt invoke mit einem
      // Fehler durch — der UI-State spiegelt das.
      greeting = await invoke<string>('greet', { name });
    } catch (e) {
      greeting = '';
      error = e instanceof Error ? e.message : String(e);
    }
  }
</script>

<section>
  <h1>GridGuide</h1>
  <p>
    Skelett-Stand aus M1-Welle 2. Volle UI mit Projektuebersicht,
    Profilauswahl und Export-Workflow folgt in M6.
  </p>

  <form
    on:submit|preventDefault={onGreet}
    aria-labelledby="greet-form-title"
  >
    <h2 id="greet-form-title">Tauri-Command-Demo</h2>

    <label>
      Name
      <input
        type="text"
        bind:value={name}
        placeholder="Name eingeben"
        data-testid="name-input"
      />
    </label>

    <button type="submit" data-testid="greet-button">Begruessen</button>
  </form>

  {#if greeting}
    <output data-testid="greeting-output" aria-live="polite">{greeting}</output>
  {/if}

  {#if error}
    <p role="alert" data-testid="error-message" class="error">{error}</p>
  {/if}
</section>

<style>
  section {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  h1 {
    margin: 0;
    font-size: 2rem;
  }

  form {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    padding: 1rem;
    background: white;
    border-radius: 8px;
    border: 1px solid #d2d2d7;
  }

  label {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-weight: 500;
  }

  input {
    padding: 0.5rem 0.75rem;
    font-size: 1rem;
    border: 1px solid #d2d2d7;
    border-radius: 6px;
  }

  button {
    padding: 0.6rem 1rem;
    font-size: 1rem;
    background: #0066cc;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
  }

  button:hover {
    background: #0052a3;
  }

  output {
    padding: 0.75rem 1rem;
    background: #e8f4ff;
    border-left: 3px solid #0066cc;
    border-radius: 4px;
  }

  .error {
    padding: 0.75rem 1rem;
    background: #ffe6e6;
    border-left: 3px solid #cc0000;
    border-radius: 4px;
    margin: 0;
  }
</style>

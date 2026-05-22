import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/svelte';
import userEvent from '@testing-library/user-event';
import Page from './+page.svelte';

// Mock fuer Tauri's invoke — die Seite laeuft im Test im jsdom ohne
// Tauri-Host. Wir stellen sicher, dass das Form-Wiring stimmt und
// die Antwort des Commands im UI angezeigt wird (vgl. ADR 0004 §2.2
// und GG-NFA-COV-001).
vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn()
}));

describe('+page.svelte (Hello-Skelett)', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('rendert Ueberschrift und Demo-Formular', () => {
    render(Page);
    expect(screen.getByRole('heading', { name: 'GridGuide' })).toBeInTheDocument();
    expect(screen.getByTestId('name-input')).toBeInTheDocument();
    expect(screen.getByTestId('greet-button')).toBeInTheDocument();
  });

  it('ruft den greet-Tauri-Command mit dem eingegebenen Namen', async () => {
    const { invoke } = await import('@tauri-apps/api/core');
    (invoke as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
      'Hello, Alice, from GridGuide!'
    );

    render(Page);
    const user = userEvent.setup();

    await user.type(screen.getByTestId('name-input'), 'Alice');
    await user.click(screen.getByTestId('greet-button'));

    expect(invoke).toHaveBeenCalledWith('greet', { name: 'Alice' });
    expect(await screen.findByTestId('greeting-output')).toHaveTextContent(
      'Hello, Alice, from GridGuide!'
    );
  });

  it('zeigt Fehlermeldung, wenn der Command fehlschlaegt', async () => {
    const { invoke } = await import('@tauri-apps/api/core');
    (invoke as unknown as ReturnType<typeof vi.fn>).mockRejectedValue(
      new Error('Tauri-Host nicht verfuegbar')
    );

    render(Page);
    const user = userEvent.setup();

    await user.click(screen.getByTestId('greet-button'));

    const error = await screen.findByTestId('error-message');
    expect(error).toHaveTextContent('Tauri-Host nicht verfuegbar');
  });
});

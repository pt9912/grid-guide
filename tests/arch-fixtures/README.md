# tests/arch-fixtures/ — Verstossfixtures fuer `tools/arch-check.sh`

Dieses Verzeichnis enthaelt bewusste Verstoesse gegen die hexagonalen
Tabu-Regeln. Sie dienen nicht der Produktivkompilation, sondern als
Pruefstein fuer `tools/arch-check.sh`:

```sh
make arch-check                         # gruen (real-Tree clean)
ARCH_CHECK_FIXTURES=on make arch-check  # rot   (Fixtures werden geflagt)
```

Wenn der zweite Aufruf gruen meldet, ist `arch-check.sh` selbst
defekt. Das ist Teil der Verifikation aus M1-Slice-Plan §3 Welle 4.

## Konvention

- Jede Fixture-Datei entspricht genau einer Regel.
- Die Verzeichnisstruktur spiegelt `src-tauri/src/hexagon/`:
  - `core/` fuer Verstoesse gegen Rule A (Core-Isolation).
  - `ports/` fuer Verstoesse gegen Rule B (impl-Bloecke in Ports).
- Die Dateien sind valides Rust-Syntax, aber **nicht** Teil des
  Cargo-Builds (liegen ausserhalb `src-tauri/`). Sie werden vom
  Compiler ignoriert.

Die Fixtures duerfen erweitert werden, sobald neue Regeln dazukommen
(z. B. Rule D: echte Zyklen-Erkennung via `cargo modules` in M2+).

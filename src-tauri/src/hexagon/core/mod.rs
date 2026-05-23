// Fachlicher Kern — domain, use_cases, vokabulare.
//
// Aufbau gemaess Roadmap M2..M7:
//   - vocab/  : Kontrollierte Vokabulare (Enums) gemaess GG-DATA-004.
//               Behavior-arm, aber wegen Coverage-Wirkung trotzdem
//               vollstaendig mit serde-Round-Trip-Tests gedeckt.
//   - domain/ : Immutable Domain-Strukturen (M2-Welle 2).
//   - seed/   : In-Memory-Seed-Daten (M2-Welle 3 + 4).
//   - use_cases/ : Application-Services (M3+).

pub mod domain;
pub mod vocab;

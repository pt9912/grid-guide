// Adapter setzen die Ports gegen konkrete Technik um.
//
// - driving: Eingangsadapter, die Use-Cases aufrufen
//   (z. B. Tauri-Commands, CLI).
// - driven: Ausgangsadapter, die driven-Ports implementieren
//   (z. B. PDF-Reader-Adapter, Dateisystem-Persistenz).
//
// Adapter duerfen keine Businesslogik enthalten (GG-CC-002).

pub mod driven;
pub mod driving;

// Ports: Schnittstellen zwischen Kern und Adaptern.
//
// - driving: Eingangs-Ports, die von Adaptern aufgerufen werden,
//   um Use-Cases zu starten (z. B. Tauri-Commands, CLI).
// - driven: Ausgangs-Ports, die der Kern aufruft, um mit der
//   Aussenwelt zu sprechen (z. B. PDF-Reader, Persistenz, HTTP).

pub mod driven;
pub mod driving;

# Kiddotronic Q15 – iPhone Bluetooth Test

Erste Diagnose-App für den Kiddotronic Q15 Mini KI Printer.

## Funktionen
- BLE-Geräte in der Nähe scannen
- Q15 auswählen und verbinden
- alle GATT Services und Characteristics ermitteln
- WRITE / WRITE_NO_RESPONSE / NOTIFY markieren
- Diagnoseprotokoll direkt vom iPhone teilen

## Auf dem iPhone testen

### Voraussetzungen
- Mac mit aktuellem Xcode
- iPhone
- Apple-ID (für Installation auf dem eigenen Gerät genügt grundsätzlich auch ein kostenloses Personal Team; TestFlight/App Store Distribution benötigt das Apple Developer Program)
- Homebrew optional

### Projekt erzeugen
Dieses Repository verwendet XcodeGen, damit keine große `.xcodeproj`-Datei manuell gepflegt werden muss.

```bash
brew install xcodegen
cd q15-ios-test
xcodegen generate
open KiddotronicQ15Test.xcodeproj
```

### In Xcode
1. Target `KiddotronicQ15Test` öffnen.
2. Signing & Capabilities öffnen.
3. Dein Apple Team auswählen.
4. Falls nötig Bundle Identifier ändern, bis er eindeutig ist.
5. iPhone per Kabel/WLAN auswählen.
6. Run ▶ drücken.
7. Auf dem iPhone Bluetooth erlauben.

### Q15 untersuchen
1. Q15 einschalten und in die Nähe des iPhones legen.
2. `Q15 / BLE-Geräte suchen` drücken.
3. Q15 bzw. das passende Printer-Gerät antippen.
4. Nach erfolgreicher Verbindung werden Services und Characteristics automatisch gelesen.
5. `Diagnose teilen` drücken und das Protokoll sichern.

## Nächster Schritt
Anhand der WRITE-/NOTIFY-Characteristics wird die Druckschnittstelle identifiziert. Erst danach wird ein kontrollierter Testdruck implementiert. Es werden in dieser Version bewusst keine unbekannten Rohbefehle an den Drucker gesendet.

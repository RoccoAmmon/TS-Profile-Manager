# TS Profile Manager

Moderne WPF-GUI zur Verwaltung von Terminalserver-Profilen auf mehreren Freigaben.

## Funktionen

- **Multi-Freigabe**: Beliebig viele Profil- und Replika-Freigaben gleichzeitig verwalten
- **Sortierbare DataGrid**: Nach Name, Größe oder Anzahl Freigaben sortieren
- **Filter**: Profile nach einzelner Freigabe filtern
- **Groessenberechnung**: Ermittelt die tatsaechliche Groesse jedes Profils rekursiv
- **Loeschen**: Profile von allen Freigaben mit Bestaetigungsdialog entfernen
- **CSV-Export**: Uebersicht als CSV-Datei exportieren
- **Konfigurations-Persistenz**: Freigaben werden in einer JSON-Datei gespeichert und beim Start automatisch geladen

## Voraussetzungen

- Windows PowerShell 5.1 oder PowerShell 7+
- .NET Framework 4.5+ (fuer WPF)
- Lese-/Schreibzugriff auf die konfigurierten Netzwerkfreigaben

## Verwendung

```powershell
.\TS-Profile-Manager_2.0.ps1
```

Beim ersten Start oeffnet sich der Konfigurationsdialog:
1. **Profil-Freigaben (Primaer)**: Server und Freigabe eingeben, via `Hinzufuegen` uebernehmen
2. **Profilreplika-Freigaben (Sekundaer)**: Gleiches Vorgehen fuer Replika-Freigaben
3. Mit `OK`bestaetigen - die Konfiguration wird automatisch gespeichert

Beim naechsten Start werden die gespeicherten Freigaben automatisch geladen.

## Konfigurationsdatei

Die gespeicherten Freigaben liegen als `TS-Profile-Manager.config.json` im Skript-Verzeichnis.

## Hinweise

- Das Skript benoetigt einen STA-Thread (Single-Threaded Apartment). PowerShell Desktop startet standardmaessig mit STA.
- Bei PowerShell 7 muss ggf. `-STA` Parameter verwendet werden.
- Die Groessenberechnung kann bei vielen Profilen einige Minuten dauern.

## Lizenz

Siehe [LICENSE](LICENSE)

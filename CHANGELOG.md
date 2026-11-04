# Changelog

## 2.6 (2026-11-04)

Kompletter Relaunch: Die WPF-Version wird durch eine schnellerere WinForms-Version
mit gleichem Design ersetzt (Datei weiterhin `TS-Profile-Manager.ps1`).

- **WinForms-Neubau** mit OwnerDraw-ListView, dunklem Header und alternierenden
  Zeilenfarben – optisch gleich zur WPF-Version, aber deutlich performanter
- **NEU: Alias-Spalte** (ganz links) – Benutzername aus dem Profilnamen
  abgeleitet: hinter `Profile_` und ohne Dateiendung (`Profile_Mustermann.VHDX` → `Mustermann`);
  falls der Ordner keine VHDX enthält, wird der Ordnernamen verwendet
- **NEU: Mehrfachauswahl** per Strg-/Shift-Klick; Statusleiste zeigt Anzahl,
  Gesamtgroesse und Namen; `Entf` loescht die Auswahl, Doppelklick oeffnet den Explorer
- **NEU: Paralleles Laden** von Groesse und Zugriffsdatum ueber einen RunspacePool;
  Thread-Anzahl konfigurierbar ueber `$script:MaxLoadThreads` im Skriptanfang (Standard 10)
- **NEU: Dynamisch resizable Fenster** (Standard 1300x740, Minimum 1150x620)
  statt fester Groesse
- **Sortierung** nach Alias (Standard), Name, Groesse, Serverstatus oder letztem Zugriff
- **Suchfilter** prueft jetzt Name und Alias
- **CSV-Export** enthaelt die Alias-Spalte
- Performance-Optimierungen: Spaltenbreiten-Cache, gecachte Zeichenobjekte,
  DoubleBuffered-Liste, Debounce-Timer fuer die Statusleiste
- Konfigurationsdatei: `TSProfileManagerConfig.json` (ServerPairs, ShowSizes, ShowLastAccess)

## 1.0.1 (2026-07-02)

- Beispiel-Shares aus Konfigurationsdialog entfernt
- Konfiguration via "Konfiguration"-Button oeffnet jetzt immer den Dialog
- "Aendern"-Button im Konfigurationsdialog zum Bearbeiten von Eintraegen
- Fenster startet mit 80% Bildschirmgroesse
- Rechtsklick-Kontextmenue zum Loeschen
- Pfad-Spalte zeigt jetzt tatsaechliche UNC-Pfade statt Anzahl
- Filter-ComboBox in der Toolbar (alle/einzelne Freigabe)
- Konfigurations-Persistenz als JSON-Datei
- Datei umbenannt von `TS-Profile-Manager_2.0.ps1` zu `TS-Profile-Manager.ps1`

## 1.0.0 (2026-07-02)

- Kompletter Rewrite als WPF-Anwendung mit XAML
- Multi-Freigabe-Unterstuetzung (Profil + Replika, beliebig viele)
- Sortierbare DataGrid (Name, Groesse, Freigaben)
- Groessenberechnung rekursiv pro Profil
- Loeschen mit Bestaetigungsdialog von allen Freigaben
- CSV-Export
- Modernes, resizebares WPF-Design mit dunklem Header
- Gesamtgroesse pro Freigabe in der Uebersicht

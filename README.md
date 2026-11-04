# TS Profile Manager

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/.NET-Framework%204.5%2B-512BD4?logo=dotnet&logoColor=white" alt=".NET">
  <img src="https://img.shields.io/badge/WinForms-GUI-00C853?logo=windows&logoColor=white" alt="WinForms">
  <img src="https://img.shields.io/badge/Version-2.6-FF6F00" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

<p align="center">
  <b>Moderne GUI zur Verwaltung von Terminalserver-Profilen auf mehreren Freigaben.</b>
</p>

---

## ✨ Features

| Feature | Beschreibung |
|---------|-------------|
| :computer: **Multi-Freigabe** | Beliebig viele Profil- und Replika-Freigaben gleichzeitig verwalten |
| :label: **Alias-Spalte** | Benutzername direkt aus dem Profilnamen abgeleitet (z.B. `Profile_barazi.VHDX` → `barazi`) |
| :point_left: **Mehrfachauswahl** | Mehrere Profile per Strg-/Shift-Klick auswaehlen; Statusleiste zeigt Anzahl, Gesamtgroesse und Namen |
| :zap: **Paralleles Laden** | Groesse und Zugriffsdatum aller Profile werden parallel abgerufen (Thread-Anzahl via `$script:MaxLoadThreads` im Skriptanfang, Standard 10) |
| :arrow_up_down: **Sortierbare Spalten** | Nach Alias, Name, Groesse, Serverstatus oder letztem Zugriff sortieren |
| :mag: **Echtzeit-Suchfilter** | Suche in Name und Alias, Live-Filterung bei der Eingabe |
| :bar_chart: **Groessenberechnung** | Ermittelt die tatsaechliche Groesse jedes Profils (Schalter AN/AUS) |
| :clock3: **Letzter Zugriff** | Spalte mit Zugriffsdatum (Schalter AN/AUS) |
| :wastebasket: **Loeschen** | Einzelne oder mehrere Profile von allen Freigaben mit Bestaetigungsdialog entfernen |
| :page_facing_up: **CSV-Export** | Uebersicht (inkl. Alias) als CSV-Datei exportieren |
| :floppy_disk: **Konfigurations-Persistenz** | Freigaben werden in einer JSON-Datei gespeichert und beim Start automatisch geladen |
| :Aa: **Schriftart** | Schriftart und -groesse der Liste per Dialog aendern |
| :art: **Dynamisches Design** | Fenster beliebig skalierbar (Minimum 1150x620), Uebersicht wie die WPF-Version |

---

## :hammer_and_wrench: Voraussetzungen

- :zap: Windows PowerShell **5.1** oder PowerShell **7+**
- :globe_with_meridians: .NET Framework **4.5+** (fuer WinForms)
- :open_file_folder: Lese-/Schreibzugriff auf die konfigurierten Netzwerkfreigaben

---

## :rocket: Verwendung

```powershell
.\TS-Profile-Manager.ps1
```

Beim ersten Start oeffnet sich der Konfigurationsdialog:

1. :gear: **Profil-Freigaben (Primaer)** – Server und Freigabe eingeben, via `Hinzufuegen` uebernehmen
2. :arrows_counterclockwise: **Profilreplika-Freigaben (Sekundaer)** – Gleiches Vorgehen fuer Replika-Freigaben
3. :white_check_mark: Mit **OK** bestaetigen – die Konfiguration wird automatisch gespeichert

Beim naechsten Start werden die gespeicherten Freigaben automatisch geladen.

**Skriptparameter (optional):**

| Parameter | Beschreibung |
|-----------|-------------|
| `-ListViewFontName` | Schriftart der Profilliste (Standard: `Consolas`) |
| `-ListViewFontSize` | Schriftgroesse in Punkt, 7-20 (Standard: `10`) |
| `-Server1` / `-Server2` | Hostnamen (nur ohne Konfigurationsdatei) |
| `-ProfilesShare` / `-ReplicaShare` | Freigabenamen (nur ohne Konfigurationsdatei) |

**Mehrfachauswahl:** Zeilen per Klick, Strg-Klick (Einzelauswahl) oder Shift-Klick (Bereich) markieren. Die Statusleiste unten zeigt Anzahl, Gesamtgroesse und Namen der Auswahl. `Entf` loescht die Auswahl, ein Doppelklick oeffnet den Explorer.

---

## :file_folder: Konfigurationsdatei

Die gespeicherten Freigaben liegen als `TSProfileManagerConfig.json` im Skript-Verzeichnis:

```json
{
    "ServerPairs": [
        {
            "Name": "Produktion",
            "ProfilePath1": "\\\\srv-prod01\\profiles$",
            "ProfilePath2": "\\\\srv-prod02\\profilesreplica$"
        }
    ],
    "ShowSizes": true,
    "ShowLastAccess": true
}
```

- **ServerPairs**: beliebig viele Profilpaare (Name, ProfilePath1, ProfilePath2) – jedes Paar bekommt einen eigenen Button in der GUI
- **ShowSizes**: Groessenberechnung ein-/ausschalten
- **ShowLastAccess**: Spalte "Letzter Zugriff" ein-/ausschalten

---

## :information_source: Hinweise

- Das Skript benoetigt einen **STA-Thread** (Single-Threaded Apartment). PowerShell Desktop startet standardmaessig mit STA.
- Bei PowerShell 7 muss ggf. der Parameter `-STA` verwendet werden.
- Die Groessenberechnung laeuft parallel (Standard: 10 Threads); die Thread-Anzahl kann ueber `$script:MaxLoadThreads` im Skriptanfang angepasst werden.
- Einloggs liegen unter `C:\ExchangeMigrationLog`.

---

## :scroll: Lizenz

Siehe [LICENSE](LICENSE)

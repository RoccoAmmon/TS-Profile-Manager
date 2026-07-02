# TS Profile Manager

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/.NET-Framework%204.5%2B-512BD4?logo=dotnet&logoColor=white" alt=".NET">
  <img src="https://img.shields.io/badge/WPF-GUI-00C853?logo=windows&logoColor=white" alt="WPF">
  <img src="https://img.shields.io/badge/Version-1.0.0-FF6F00" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

<p align="center">
  <b>Moderne WPF-GUI zur Verwaltung von Terminalserver-Profilen auf mehreren Freigaben.</b>
</p>

---

## ✨ Features

| Feature | Beschreibung |
|---------|-------------|
| :computer: **Multi-Freigabe** | Beliebig viele Profil- und Replika-Freigaben gleichzeitig verwalten |
| :arrow_up_down: **Sortierbare DataGrid** | Nach Name, Groesse oder Anzahl Freigaben sortieren |
| :mag: **Filter** | Profile nach einzelner Freigabe filtern |
| :bar_chart: **Groessenberechnung** | Ermittelt die tatsaechliche Groesse jedes Profils rekursiv |
| :wastebasket: **Loeschen** | Profile von allen Freigaben mit Bestaetigungsdialog entfernen |
| :page_facing_up: **CSV-Export** | Uebersicht als CSV-Datei exportieren |
| :floppy_disk: **Konfigurations-Persistenz** | Freigaben werden in einer JSON-Datei gespeichert und beim Start automatisch geladen |

---

## :hammer_and_wrench: Voraussetzungen

- :zap: Windows PowerShell **5.1** oder PowerShell **7+**
- :globe_with_meridians: .NET Framework **4.5+** (fuer WPF)
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

---

## :file_folder: Konfigurationsdatei

Die gespeicherten Freigaben liegen als `TS-Profile-Manager.config.json` im Skript-Verzeichnis.

---

## :information_source: Hinweise

- Das Skript benoetigt einen **STA-Thread** (Single-Threaded Apartment). PowerShell Desktop startet standardmaessig mit STA.
- Bei PowerShell 7 muss ggf. der Parameter `-STA` verwendet werden.
- Die Groessenberechnung kann bei vielen Profilen einige Minuten dauern.

---

## :scroll: Lizenz

Siehe [LICENCE](LICENSE)

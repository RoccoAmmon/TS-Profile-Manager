<#
.SYNOPSIS
    Terminal Server Profile Manager v2.6 - WinForms-GUI mit Alias-Spalte,
    Suchfilter, Mehrfachauswahl und parallelem Laden der Profil-Details

.DESCRIPTION
    Vollstaendig ueberarbeitete Version (WinForms, Design der WPF-Vorlage) mit:
    - Moderne GUI mit OwnerDraw-ListView und 6 Spalten
    - NEU: Spalte "Alias" (ganz links), aus dem Profilnamen abgeleitet,
      z.B. "Profile_Mustermann.VHDX" -> "Mustermann"
    - NEU: Mehrfachauswahl per Strg-/Shift-Klick; die Statusleiste zeigt
      Anzahl, Gesamtgroesse und Namen der Auswahl
    - NEU: Paralleles Laden von Groesse und Zugriffsdatum ueber einen
      RunspacePool; Thread-Anzahl ueber $script:MaxLoadThreads (Skriptanfang)
    - NEU: Dynamisch resizable Fenster (Minimum 1150x620)
    - Echtzeit-Suchfilter (sucht in Name UND Alias)
    - Spaltenklick-Sortierung (Alias, Name, Groesse, Serverstatus, Zugriff)
      mit Richtungsanzeige, Standard-Sortierung nach Alias (A-Z)
    - Alternierende Zeilenfarben und dunkle Spaltenueberschriften
    - Einstellbare Schriftart und -groesse (per Parameter und GUI-FontDialog)
    - Mehrere Profilpaare (Profil + Replikat) aus der Konfigurationsdatei,
      je Paar ein eigener Button in der GUI (Beschriftung = "Name" aus der
      Config, aktives Paar blau markiert)
    - Groessen-Schalter in der GUI (AN/AUS), wird in der Konfigurationsdatei gespeichert
    - Konfigurationsmanager zum Anlegen/Aendern/Entfernen der Freigaben
    - Spalte "Letzter Zugriff" mit eigenem Schalter (AN/AUS), wird in der
      Konfigurationsdatei gespeichert
    - CSV-Export inkl. Alias-Spalte
    - Schnelles Neuladen durch gedaemmtes Status-Update (kein Repaint pro Profil)
    - Datei-Logging unter C:\ExchangeMigrationLog
    - Verbesserte Fehlerbehandlung mit Try/Catch in allen Funktionen

.PARAMETER Server1
    Hostname des ersten Dateiservers. Wird nur verwendet, wenn kein
    Profilpfad in der Konfigurationsdatei TSProfileManagerConfig.json
    hinterlegt ist (Standard: servername).

.PARAMETER Server2
    Hostname des zweiten Dateiservers. Wird nur verwendet, wenn kein
    Profilpfad in der Konfigurationsdatei TSProfileManagerConfig.json
    hinterlegt ist (Standard: servername).

.PARAMETER ProfilesShare
    Name der Profilfreigabe auf Server 1 (Standard: profiles$)

.PARAMETER ReplicaShare
    Name der Replikatfreigabe auf Server 2 (Standard: profilesreplica$)

.PARAMETER ListViewFontName
    Name der Schriftart fuer die Profilliste (Standard: Consolas)

.PARAMETER ListViewFontSize
    Schriftgroesse fuer die Profilliste in Punkt, 7-20 (Standard: 10)

.NOTES
    Version: 1.0 - Initiale Version
    Version: 1.2 - Korrigierte String-Formatierung
    Version: 1.4 - Korrektur bei langen Dateinamen ueber 35 Zeichen
    Version: 2.0 - Modernisierte GUI, Suchfilter, Namenssortierung, Datei-Logging
    Version: 2.1 - Einstellbare Schriftart per Parameter und GUI-FontDialog
                   ASCII-sichere Version (keine Unicode-/Emoji-Zeichen)
    Version: 2.2 - Konfigurationsdatei TSProfileManagerConfig.json (neben dem Skript):
                   - ProfilePath1 / ProfilePath2 : die beiden UNC-Profilpfade
                   - ShowSizes (true/false)      : Ordner-Groessen auslesen und anzeigen
                   Die Konfiguration wird beim Start automatisch geladen; fehlt die
                   Datei, wird sie mit Standardwerten neu angelegt. Die Eintraege in
                   der Konfigurationsdatei haben Vorrang vor den Parametern.
    Version: 2.3 - Mehrere Profilpaare (Profil + Replikat) in der Konfigurationsdatei
                   unter "ServerPairs" (Name, ProfilePath1, ProfilePath2). Der Button
                   "Profilpaar: <Name> [Wechseln]" in der GUI wechselt zum naechsten
                   Paar und laedt die Profilliste neu. "Name" steuert die
                   Button-Beschriftung. Das alte Format mit einzelnen
                   ProfilePath1/ProfilePath2 wird weiterhin unterstuetzt.
    Version: 2.4 - Groessen-Schalter in der GUI ("Groessen: AN/AUS"), Wert wird in der
                   Konfigurationsdatei gespeichert. Buttons oben nebeneinander.
                   Performance: Status-Update nur noch alle 25 Profile, kein
                   erzwungenes Form.Refresh pro Profil -> schnelleres Neuladen/Wechseln.
    Version: 2.5 - Je Profilpaar ein eigener Button in der GUI (einer pro Eintrag in
                   "ServerPairs", Beschriftung = "Name"). Klick wechselt direkt zum
                   Paar, das aktive Paar wird blau hervorgehoben.
    Version: 2.6 - Design an die WPF-Vorlage (fruehere WPF-Version, jetzt durch
                   diese WinForms-Version ersetzt) angepasst (nur optisch,
                   alle Funktionen erhalten):
                   - Dunkler Header (#2D3E50) mit Titel/Untertitel und blauem
                     Akzentbalken (#3498DB)
                   - Monospace-Pfadzeilen unter dem Header
                   - Button-Leiste im Design der WPF-Version (Profil loeschen,
                     Aktualisieren, CSV exportieren, Konfiguration, Filter, Beenden)
                   - Liste mit dunklen Spaltenueberschriften (#34495E/Weiss) und
                     alternierenden Zeilenfarben (#F5F7FA) wie das DataGrid
                   - Statusleiste (#ECF0F1) und Copyright unten links
                   - NEU: Konfigurationsmanager ueber den Button "Konfiguration"
                   - NEU: Spalte "Letzter Zugriff" mit Schalter
                     "Letzter Zugriff: AN/AUS" (wie Groessen: AN/AUS, Wert wird in
                     der Konfigurationsdatei gespeichert)
                   - NEU: Spalte "Alias" (ganz links) aus dem Profilnamen
                     abgeleitet, z.B. "Profile_Mustermann.VHDX" -> "Mustermann"
                   - NEU: Mehrfachauswahl per Strg-/Shift-Klick inkl.
                     Statusanzeige (Anzahl, Gesamtgroesse, Namen)
                   - NEU: Paralleles Laden von Groesse/Zugriffsdatum ueber
                     RunspacePool, Thread-Anzahl via $script:MaxLoadThreads
                     (Variable im Skriptanfang, Standard 10)
                   - NEU: Dynamisch resizable Fenster (Standard 1300x740,
                     Minimum 1150x620)
    Autor:   Rocco Ammon
    Datum:   2025-2026

.EXAMPLE
    .\TS-Profile-Manager.ps1
    Startet den Profile Manager mit Standardeinstellungen (Consolas, 10pt).

.EXAMPLE
    .\TS-Profile-Manager.ps1 -ListViewFontSize 12
    Startet den Profile Manager mit groesserer Schrift (12pt).

.EXAMPLE
    .\TS-Profile-Manager.ps1 -ListViewFontName "Courier New" -ListViewFontSize 11
    Startet den Profile Manager mit Courier New in 11pt.

.EXAMPLE
    .\TS-Profile-Manager.ps1 -Server1 "fileserver01" -Server2 "fileserver02"
    Startet den Profile Manager mit benutzerdefinierten Servernamen.

.EXAMPLE
    Konfiguration ueber die Datei TSProfileManagerConfig.json (neben dem Skript):
    { "ServerPairs": [
        { "Name": "Produktion",
          "ProfilePath1": "\\\\srv-prod01\\profiles$",
          "ProfilePath2": "\\\\srv-prod02\\profilesreplica$" },
        { "Name": "Test",
          "ProfilePath1": "\\\\srv-test01\\testprofiles$",
          "ProfilePath2": "\\\\srv-test02\\testprofilesreplica$" }
      ],
      "ShowSizes": true,
      "ShowLastAccess": false }
    Startet den Profile Manager mit den konfigurierten Profilpaaren. Der Button
    "Profilpaar: <Name> [Wechseln]" in der GUI springt zwischen den Paaren.
    Bei "ShowSizes": false werden die Ordner-Groessen nicht ausgelesen und als
    "-" angezeigt (schnelleres Laden bei vielen Profilen).
    Bei "ShowLastAccess": true wird das Datum des letzten Zugriffs je Profilordner
    angezeigt (Spalte "Letzter Zugriff").
#>

param(
    [string]$Server1        = "servername",
    [string]$Server2        = "servername",
    [string]$ProfilesShare  = "profiles$",
    [string]$ReplicaShare   = "profilesreplica$",

    # Schriftart-Einstellungen fuer die ListView (aenderbar zur Laufzeit ueber GUI)
    [string]$ListViewFontName = "Arial Narrow",
    [ValidateRange(7, 20)]
    [int]$ListViewFontSize    = 9
)

# ============================================================
# Assemblies laden
# ============================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# WPF-Assemblyn fuer den Konfigurationsdialog (wie TS-Profile-Manager.ps1)
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ============================================================
# Globale Variablen (am Anfang definiert)
# ============================================================

# --- UNC-Pfade zu den Profilfreigaben ---
$script:ProfilePath1            = "\\$Server1\$ProfilesShare"
$script:ProfilePath2            = "\\$Server2\$ReplicaShare"

# --- Konfigurationsdatei laden (TSProfileManagerConfig.json neben dem Skript) ---
$script:ScriptDir               = if ($PSScriptRoot) { $PSScriptRoot } else { '.' }
$script:ConfigFile              = Join-Path $script:ScriptDir "TSProfileManagerConfig.json"
$script:ShowSizes               = $true    # Ordner-Groessen auslesen und anzeigen? (aus Konfiguration)
$script:ShowLastAccess          = $false   # Datum des letzten Zugriffs anzeigen? (aus Konfiguration)
$script:ServerPairs             = @()     # Liste der Profilpaare: Name, ProfilePath1, ProfilePath2
$script:CurrentPairIndex        = 0

if (Test-Path $script:ConfigFile) {
    try {
        $config = Get-Content -Path $script:ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json

        # Neues Format: ServerPairs = [{Name, ProfilePath1, ProfilePath2}, ...]
        if ($config.ServerPairs) {
            foreach ($sp in @($config.ServerPairs)) {
                if ($sp.ProfilePath1 -and $sp.ProfilePath2) {
                    $script:ServerPairs += [PSCustomObject]@{
                        Name         = if ($sp.Name) { [string]$sp.Name } else { "Profilpaar $($script:ServerPairs.Count + 1)" }
                        ProfilePath1 = [string]$sp.ProfilePath1
                        ProfilePath2 = [string]$sp.ProfilePath2
                    }
                }
            }
        }
        # Altes Format: einzelne ProfilePath1/ProfilePath2 -> ein Paar
        elseif ($config.ProfilePath1 -and $config.ProfilePath2) {
            $script:ServerPairs += [PSCustomObject]@{
                Name         = "Standard"
                ProfilePath1 = [string]$config.ProfilePath1
                ProfilePath2 = [string]$config.ProfilePath2
            }
        }

        if ($null -ne $config.ShowSizes) {
            $script:ShowSizes = if ($config.ShowSizes -is [bool]) { $config.ShowSizes }
                                else { $config.ShowSizes -match '^(true|1|ja|yes)$' }
        }
        if ($null -ne $config.ShowLastAccess) {
            $script:ShowLastAccess = if ($config.ShowLastAccess -is [bool]) { $config.ShowLastAccess }
                                     else { $config.ShowLastAccess -match '^(true|1|ja|yes)$' }
        }
        Write-Host "[OK] Konfiguration geladen: $script:ConfigFile ($($script:ServerPairs.Count) Profilpaar(e), ShowSizes=$script:ShowSizes, ShowLastAccess=$script:ShowLastAccess)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Konfigurationsdatei konnte nicht gelesen werden: $($_.Exception.Message) - verwende Parameter/Defaults."
    }
}
else {
    # Konfigurationsdatei als Vorlage mit aktuellen Werten anlegen
    try {
        [PSCustomObject]@{
            ServerPairs = @(
                [PSCustomObject]@{
                    Name         = "Standard"
                    ProfilePath1 = $script:ProfilePath1
                    ProfilePath2 = $script:ProfilePath2
                }
            )
            ShowSizes   = $script:ShowSizes
            ShowLastAccess = $script:ShowLastAccess
        } | ConvertTo-Json -Depth 4 | Set-Content -Path $script:ConfigFile -Encoding UTF8
        Write-Host "[OK] Konfigurationsdatei neu angelegt: $script:ConfigFile (bitte Pfade eintragen)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Konfigurationsdatei konnte nicht angelegt werden: $($_.Exception.Message)"
    }
}

# Fallback: Parameter verwenden, wenn keine Paare aus der Konfiguration stammen
if ($script:ServerPairs.Count -eq 0) {
    $script:ServerPairs += [PSCustomObject]@{
        Name         = "Standard"
        ProfilePath1 = $script:ProfilePath1
        ProfilePath2 = $script:ProfilePath2
    }
    Write-Host "[WARN] Keine Profilpaare in der Konfiguration - verwende Parameter/Defaults." -ForegroundColor Yellow
}

# Erstes Profilpaar aktivieren
$script:CurrentPairIndex = 0
$script:ProfilePath1     = $script:ServerPairs[0].ProfilePath1
$script:ProfilePath2     = $script:ServerPairs[0].ProfilePath2

# --- Profildaten und Auswahl ---
$script:SelectedProfile         = $null
$script:SelectedProfiles        = @()
$script:ProfileData             = @()
$script:ProfileDataIndex        = @{}      # Name -> Profilobjekt (schnelle Nachschlage-Operation)

# --- paralleles Laden: maximale Worker-Threads fuer Groesse/Zugriffsdatum ---
# (SMB ist latenzgebunden - mehr Threads = kuerzere Gesamtladezeit)
$script:MaxLoadThreads             = 10

# --- Sortierung (Standard: nach Alias/Name aufsteigend) ---
$script:SortColumn              = 0
$script:SortAscending           = $true
$script:ColumnNames             = @("Alias", "Name", "Groesse", "Server 1", "Server 2", "Letzter Zugriff")
$script:ColumnWidths            = @(170, 490, 140, 150, 150, 170)

# --- Schriftart-Einstellungen (aenderbar ueber GUI oder Parameter) ---
$script:ListViewFontName        = $ListViewFontName
$script:ListViewFontSize        = $ListViewFontSize

# --- Logging ---
$script:LogPath                 = "C:\ExchangeMigrationLog"
$script:LogFile                 = Join-Path $script:LogPath ("TSProfileManager_" + (Get-Date -Format 'yyyyMMdd') + ".log")

# --- GUI-Farbschema (Design der WPF-Version TS-Profile-Manager.ps1) ---
$script:ColorFormBackground     = [System.Drawing.Color]::FromArgb(242, 242, 247)   # #F2F2F7 Fensterhintergrund
$script:ColorHeaderBackground   = [System.Drawing.Color]::FromArgb(45, 62, 80)      # #2D3E50 Header
$script:ColorAccentBar          = [System.Drawing.Color]::FromArgb(52, 152, 219)    # #3498DB Akzentbalken
$script:ColorAccentBlue         = [System.Drawing.Color]::FromArgb(41, 128, 185)    # #2980B9
$script:ColorAccentDarkBlue     = [System.Drawing.Color]::FromArgb(52, 73, 94)      # #34495E
$script:ColorGridHeader         = [System.Drawing.Color]::FromArgb(52, 73, 94)      # #34495E Spaltenueberschriften
$script:ColorStatusBarBackground= [System.Drawing.Color]::FromArgb(236, 240, 241)   # #ECF0F1 Statusleiste
$script:ColorSuccess            = [System.Drawing.Color]::FromArgb(40, 167, 69)
$script:ColorDanger             = [System.Drawing.Color]::FromArgb(192, 57, 43)     # #C0392B
$script:ColorDangerHover        = [System.Drawing.Color]::FromArgb(180, 30, 40)
$script:ColorExport             = [System.Drawing.Color]::FromArgb(39, 174, 96)     # #27AE60
$script:ColorExplorer           = [System.Drawing.Color]::FromArgb(108, 117, 125)
$script:ColorFont               = [System.Drawing.Color]::FromArgb(70, 130, 180)
$script:ColorExit               = [System.Drawing.Color]::FromArgb(149, 165, 166)   # #95A5A6
$script:ColorRowAlternate       = [System.Drawing.Color]::FromArgb(245, 247, 250)   # #F5F7FA
$script:ColorRowNormal          = [System.Drawing.Color]::White
$script:ColorServerOK           = [System.Drawing.Color]::FromArgb(40, 167, 69)
$script:ColorServerFail         = [System.Drawing.Color]::FromArgb(200, 40, 50)

# --- GUI-Steuerelemente (werden in Initialize-GUI befuellt) ---
$script:Form                    = $null
$script:ListView                = $null
$script:TextBoxSearch           = $null
$script:ButtonDelete            = $null
$script:ButtonExplorer          = $null
$script:LabelStatus             = $null
$script:LabelProfileCount       = $null
$script:LabelFontInfo           = $null
$script:LabelServer1            = $null
$script:LabelServer2            = $null
$script:PairButtons             = @()   # ein Button pro Profilpaar
$script:PairButtonParent        = $null # Container, in dem die Paar-Buttons liegen
$script:ButtonToggleSizes       = $null
$script:ButtonToggleLastAccess  = $null
$script:ButtonConfig            = $null

# ============================================================
# Ausfuehrungsrichtlinie automatisch setzen
# ============================================================
function Set-AutoExecutionPolicy {
    <#
    .SYNOPSIS
        Setzt die Ausfuehrungsrichtlinie auf Bypass fuer den aktuellen Prozess
    #>
    try {
        $currentPolicy = Get-ExecutionPolicy -Scope Process
        if ($currentPolicy -eq 'Restricted') {
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
            Write-Host "[OK] Ausfuehrungsrichtlinie auf Bypass gesetzt." -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Konnte Ausfuehrungsrichtlinie nicht setzen: $($_.Exception.Message)"
    }
}
Set-AutoExecutionPolicy

# ============================================================
# Logging-Funktionen
# ============================================================

function Initialize-LogDirectory {
    <#
    .SYNOPSIS
        Erstellt das Log-Verzeichnis C:\ExchangeMigrationLog falls nicht vorhanden
    #>
    try {
        if (-not (Test-Path -Path $script:LogPath)) {
            New-Item -Path $script:LogPath -ItemType Directory -Force | Out-Null
            Write-Host "[OK] Log-Verzeichnis erstellt: $script:LogPath" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Log-Verzeichnis konnte nicht erstellt werden: $($_.Exception.Message)"
    }
}

function Write-Log {
    <#
    .SYNOPSIS
        Schreibt eine Nachricht in die Konsole und in die Log-Datei
    .PARAMETER Message
        Die zu protokollierende Nachricht
    .PARAMETER Type
        Der Log-Level: Info, Warning oder Error
    #>
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Type = "Info"
    )

    try {
        $timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Type] $Message"

        # Konsolenausgabe mit Farbcodierung
        switch ($Type) {
            "Info"    { Write-Host $logMessage -ForegroundColor Green }
            "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
            "Error"   { Write-Host $logMessage -ForegroundColor Red }
        }

        # In Log-Datei schreiben (C:\ExchangeMigrationLog)
        try {
            Add-Content -Path $script:LogFile -Value $logMessage -Encoding UTF8 -ErrorAction SilentlyContinue
        }
        catch {
            # Stille Fehlerbehandlung - Log-Datei-Schreibfehler nicht eskalieren
        }
    }
    catch {
        Write-Host "Log-Fehler: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Log-Verzeichnis beim Start initialisieren
Initialize-LogDirectory

# ============================================================
# Hilfsfunktionen
# ============================================================

function Test-ServerConnection {
    <#
    .SYNOPSIS
        Prueft die Erreichbarkeit eines UNC-Pfads
    .PARAMETER Path
        Der zu pruefende UNC-Pfad
    #>
    param([string]$Path)

    try {
        return (Test-Path -Path $Path -ErrorAction Stop)
    }
    catch {
        Write-Log -Message "Verbindungstest fehlgeschlagen fuer '$Path': $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Get-FolderSize {
    <#
    .SYNOPSIS
        Berechnet die Gesamtgroesse eines Ordners rekursiv
    .PARAMETER Path
        Der Ordnerpfad dessen Groesse berechnet werden soll
    .OUTPUTS
        [long] Groesse in Bytes, 0 wenn leer, -1 bei Fehler
    #>
    param([string]$Path)

    try {
        if (-not (Test-Path $Path)) {
            return 0
        }

        $size = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum |
                Select-Object -ExpandProperty Sum

        if ($null -eq $size) { $size = 0 }
        return [long]$size
    }
    catch {
        Write-Log -Message "Fehler bei Groessenberechnung fuer '$Path': $($_.Exception.Message)" -Type Warning
        return -1
    }
}

function Format-FileSize {
    <#
    .SYNOPSIS
        Formatiert eine Byte-Angabe in eine lesbare Groessenangabe (KB, MB, GB, TB)
    .PARAMETER Bytes
        Die Groesse in Bytes
    #>
    param([long]$Bytes)

    try {
        if ($Bytes -eq -1) { return "Fehler" }
        if ($Bytes -eq 0)  { return "0 B" }

        $sizes = @("B", "KB", "MB", "GB", "TB")
        $index = 0
        $size  = [double]$Bytes

        while ($size -ge 1024 -and $index -lt ($sizes.Length - 1)) {
            $size = $size / 1024
            $index++
        }

        return "{0:N2} {1}" -f $size, $sizes[$index]
    }
    catch {
        Write-Log -Message "Fehler bei Groessenformatierung: $($_.Exception.Message)" -Type Warning
        return "Unbekannt"
    }
}

function Get-ProfileAlias {
    <#
    .SYNOPSIS
        Leitet den Alias (Benutzernamen) aus einem Profilnamen ab
    .DESCRIPTION
        Entfernt die Dateiendung (.VHDX/.VHD) und ein fuehrendes
        "Profile_"-Praefix. Beispiele:
          "Profile_Mustermann.VHDX" -> "Mustermann"
          "Mustermann"              -> "Mustermann"
    .PARAMETER Name
        Profilname (Ordner- oder Dateiname)
    .OUTPUTS
        [string] Der Alias; "-" bei leerem Eingabewert
    #>
    param([string]$Name)

    try {
        if ([string]::IsNullOrWhiteSpace($Name)) { return "-" }
        $a = $Name.Trim()

        # Dateiendung entfernen (.VHDX / .VHD)
        $dot = $a.LastIndexOf('.')
        if ($dot -gt 0 -and $a.Length -gt 4) {
            $ext = $a.Substring($dot)
            if ($ext -match '^(?i)\.vhdx?$') { $a = $a.Substring(0, $dot) }
        }

        # Fuehrendes "Profile_"-Praefix entfernen
        if ($a.Length -ge 8 -and $a.Substring(0, 8) -eq "Profile_") {
            $a = $a.Substring(8)
        }

        $a = $a.Trim()
        if ([string]::IsNullOrWhiteSpace($a)) { return "-" }
        return $a
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($Name)) { return "-" }
        return $Name.Trim()
    }
}

# ============================================================
# Zeichen-Caches (Performance: Objekte werden wiederverwendet
# statt bei jedem Paint neu erzeugt zu werden)
# ============================================================
$script:BrushCache    = @{}
$script:StringFormats = $null
$script:PenSeparator  = $null
$script:ColWidthCache = $null   # int[] der Spaltenbreiten (siehe Update-ColumnWidthCache)

function Get-CachedBrush {
    <#
    .SYNOPSIS
        Liefert einen gecachten SolidBrush fuer eine Farbe (wiederverwendet)
    #>
    param([System.Drawing.Color]$Color)

    $key = $Color.ToArgb()
    $brush = $script:BrushCache[$key]
    if ($null -eq $brush) {
        $brush = New-Object System.Drawing.SolidBrush($Color)
        $script:BrushCache[$key] = $brush
    }
    return $brush
}

function Get-StringFormat {
    <#
    .SYNOPSIS
        Liefert ein gecachtes StringFormat (Near/Far/Center, vertikal zentriert)
    #>
    param([string]$Alignment = "Near")

    if ($null -eq $script:StringFormats) {
        $script:StringFormats = @{}
        foreach ($a in @("Near", "Far", "Center")) {
            $sf = New-Object System.Drawing.StringFormat
            $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
            $sf.Alignment     = [System.Drawing.StringAlignment]::$a
            $script:StringFormats[$a] = $sf
        }
    }
    return $script:StringFormats[$Alignment]
}

function Get-SeparatorPen {
    <#
    .SYNOPSIS
        Liefert den gecachten Trennlinien-Pen der Zeilen
    #>
    if ($null -eq $script:PenSeparator) {
        $script:PenSeparator = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(227, 231, 235), 1)
    }
    return $script:PenSeparator
}

function Get-ProfileLastAccess {
    <#
    .SYNOPSIS
        Ermittelt das Datum des letzten Zugriffs auf einen Profilordner
    .PARAMETER Path
        UNC-Pfad zum Profilordner
    .OUTPUTS
        [datetime] mit dem letzten Zugriffsdatum oder $null, wenn der Ordner
        nicht erreichbar ist
    #>
    param([string]$Path)

    try {
        if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
        if (-not (Test-Path -LiteralPath $Path -ErrorAction SilentlyContinue)) { return $null }

        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        return $item.LastAccessTime
    }
    catch {
        Write-Log -Message "Fehler beim Lesen des Zugriffsdatums fuer '$Path': $($_.Exception.Message)" -Type Warning
        return $null
    }
}

# ============================================================
# Profilpaar-Verwaltung (mehrere Profil+Replikat-Paare)
# ============================================================

function Update-PairDisplay {
    <#
    .SYNOPSIS
        Aktualisiert Button-Text und Server-Labels auf das aktive Profilpaar
    #>
    if ($script:ServerPairs.Count -eq 0) { return }
    $pair = $script:ServerPairs[$script:CurrentPairIndex]
    if ($script:LabelServer1) { $script:LabelServer1.Text = "Server 1 (Primaer):   $script:ProfilePath1" }
    if ($script:LabelServer2) { $script:LabelServer2.Text = "Server 2 (Replikat): $script:ProfilePath2" }

    # Aktiven Paar-Button hervorheben (blau = aktiv, grau = inaktiv)
    if ($script:PairButtons) {
        $inactiveBack = [System.Drawing.Color]::FromArgb(235, 238, 245)
        $inactiveFore = [System.Drawing.Color]::FromArgb(70, 70, 70)
        for ($i = 0; $i -lt $script:PairButtons.Count; $i++) {
            $btn = $script:PairButtons[$i]
            if ($i -eq $script:CurrentPairIndex) {
                $btn.BackColor = $script:ColorAccentBlue
                $btn.ForeColor = [System.Drawing.Color]::White
            } else {
                $btn.BackColor = $inactiveBack
                $btn.ForeColor = $inactiveFore
            }
        }
    }
}

function Select-ProfilePair {
    <#
    .SYNOPSIS
        Wechselt zu einem bestimmten Profilpaar (per eigenem Button)
    .PARAMETER Index
        0-basierter Index des Profilpaares innerhalb von $script:ServerPairs
    #>
    param([int]$Index)

    if ($Index -lt 0 -or $Index -ge $script:ServerPairs.Count) { return }
    if ($Index -eq $script:CurrentPairIndex) { return }   # schon aktiv -> nichts tun

    $script:CurrentPairIndex = $Index
    $pair                    = $script:ServerPairs[$Index]
    $script:ProfilePath1     = $pair.ProfilePath1
    $script:ProfilePath2     = $pair.ProfilePath2
    Update-PairDisplay
    Write-Log -Message "Profilpaar gewechselt: '$($pair.Name)' ($script:ProfilePath1 / $script:ProfilePath2)" -Type Info
    Refresh-ProfileList
}

function New-PairButtons {
    <#
    .SYNOPSIS
        Legt die Profilpaar-Buttons neu an (ein Button pro Eintrag in ServerPairs).
        Wird beim GUI-Start und nach Aenderungen im Konfigurationsdialog aufgerufen.
    #>
    try {
        if (-not $script:PairButtonParent) { return }

        # Alte Buttons entfernen
        foreach ($oldButton in @($script:PairButtons)) {
            try {
                $script:PairButtonParent.Controls.Remove($oldButton)
                $oldButton.Dispose()
            }
            catch { }
        }
        $script:PairButtons = @()

        $pairCount = $script:ServerPairs.Count
        if ($pairCount -eq 0) { return }

        # Rechte Kante und Startposition wie die Schalter-Reile darunter
        $right     = $script:Form.ClientSize.Width - 18
        $pairLeft  = $right - 603
        $pairTop   = 82
        $pairHeight = 24
        $pairGap   = 6
        $areaWidth = $right - $pairLeft
        $pairWidth = [Math]::Max(80, [Math]::Floor(($areaWidth - ($pairCount - 1) * $pairGap) / $pairCount))

        for ($i = 0; $i -lt $pairCount; $i++) {
            $pair    = $script:ServerPairs[$i]
            $btn     = New-Object System.Windows.Forms.Button
            $btnX    = [int]($right - ($pairCount * $pairWidth + ($pairCount - 1) * $pairGap) + $i * ($pairWidth + $pairGap))
            $btn.Text          = $pair.Name
            $btn.Location      = [System.Drawing.Point]::new($btnX, $pairTop)
            $btn.Size          = [System.Drawing.Size]::new([int]$pairWidth, [int]$pairHeight)
            $btn.FlatStyle     = [System.Windows.Forms.FlatStyle]::Flat
            $btn.Font          = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
            $btn.Cursor        = [System.Windows.Forms.Cursors]::Hand
            $btn.Tag           = $i
            $btn.Add_Click({
                Select-ProfilePair -Index ([int]$this.Tag)
            })
            $script:PairButtonParent.Controls.Add($btn)
            $script:PairButtons += $btn
        }

        Update-PairDisplay
    }
    catch {
        Write-Log -Message "Fehler beim Anlegen der Profilpaar-Buttons: $($_.Exception.Message)" -Type Error
    }
}

function Update-SizeToggleButton {
    <#
    .SYNOPSIS
        Aktualisiert Text und Farbe des Groessen-Schalters je nach ShowSizes-Zustand
    #>
    if (-not $script:ButtonToggleSizes) { return }
    if ($script:ShowSizes) {
        $script:ButtonToggleSizes.Text      = "Groessen:  AN"
        $script:ButtonToggleSizes.BackColor = $script:ColorServerOK
    } else {
        $script:ButtonToggleSizes.Text      = "Groessen:  AUS"
        $script:ButtonToggleSizes.BackColor = $script:ColorServerFail
    }
}

function Save-ConfigShowSizes {
    <#
    .SYNOPSIS
        Schreibt den ShowSizes-Wert zurueck in die Konfigurationsdatei
    .PARAMETER Value
        Neuer Wert fuer ShowSizes (true/false)
    #>
    param([bool]$Value)
    try {
        $config = $null
        if (Test-Path $script:ConfigFile) {
            $config = Get-Content -Path $script:ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        if (-not $config) {
            $config = [PSCustomObject]@{
                ServerPairs    = @($script:ServerPairs)
                ShowSizes      = $true
                ShowLastAccess = $script:ShowLastAccess
            }
        }
        $config.ShowSizes = $Value
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $script:ConfigFile -Encoding UTF8
        Write-Log -Message "ShowSizes($Value) in Konfigurationsdatei gespeichert: $script:ConfigFile" -Type Info
    }
    catch {
        Write-Warning "Konfigurationsdatei konnte nicht aktualisiert werden: $($_.Exception.Message)"
    }
}

function Toggle-ShowSizes {
    <#
    .SYNOPSIS
        Schaltet die Groessen-Berechnung um (AN/AUS), speichert den Wert
        in der Konfiguration und laedt die Profilliste neu
    #>
    $script:ShowSizes = -not $script:ShowSizes
    Update-SizeToggleButton
    Save-ConfigShowSizes -Value $script:ShowSizes
    Write-Log -Message "Groessen-Berechnung umgeschaltet: ShowSizes=$script:ShowSizes" -Type Info
    Refresh-ProfileList
}

function Save-ConfigShowLastAccess {
    <#
    .SYNOPSIS
        Schreibt den ShowLastAccess-Wert zurueck in die Konfigurationsdatei
    .PARAMETER Value
        Neuer Wert fuer ShowLastAccess (true/false)
    #>
    param([bool]$Value)

    try {
        $config = $null
        if (Test-Path $script:ConfigFile) {
            $config = Get-Content -Path $script:ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        if (-not $config) {
            $config = [PSCustomObject]@{
                ServerPairs = @($script:ServerPairs)
                ShowSizes   = $script:ShowSizes
            }
        }
        $config | Add-Member -NotePropertyName ShowLastAccess -NotePropertyValue $Value -Force
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $script:ConfigFile -Encoding UTF8
        Write-Log -Message "ShowLastAccess($Value) in Konfigurationsdatei gespeichert: $script:ConfigFile" -Type Info
    }
    catch {
        Write-Warning "Konfigurationsdatei konnte nicht aktualisiert werden: $($_.Exception.Message)"
    }
}

function Update-LastAccessToggleButton {
    <#
    .SYNOPSIS
        Aktualisiert Text und Farbe des Schalters fuer das Zugriffsdatum
        je nach ShowLastAccess-Zustand
    #>
    if (-not $script:ButtonToggleLastAccess) { return }
    if ($script:ShowLastAccess) {
        $script:ButtonToggleLastAccess.Text      = "Letzter Zugriff:  AN"
        $script:ButtonToggleLastAccess.BackColor = $script:ColorServerOK
    }
    else {
        $script:ButtonToggleLastAccess.Text      = "Letzter Zugriff:  AUS"
        $script:ButtonToggleLastAccess.BackColor = $script:ColorServerFail
    }
}

function Toggle-ShowLastAccess {
    <#
    .SYNOPSIS
        Schaltet die Anzeige des letzten Zugriffs um (AN/AUS), speichert den Wert
        in der Konfiguration und laedt die Profilliste neu
    #>
    $script:ShowLastAccess = -not $script:ShowLastAccess
    Update-LastAccessToggleButton
    Save-ConfigShowLastAccess -Value $script:ShowLastAccess
    Write-Log -Message "Anzeige des letzten Zugriffs umgeschaltet: ShowLastAccess=$script:ShowLastAccess" -Type Info
    Refresh-ProfileList
}

# ============================================================
# Konfigurationsmanager (WPF-Dialog aus TS-Profile-Manager.ps1)
# ============================================================

function Save-Config {
    <#
    .SYNOPSIS
        Speichert die Profilpaare und die Anzeigeoptionen in der Konfigurationsdatei
        (Format: ServerPairs mit Name/ProfilePath1/ProfilePath2, ShowSizes,
        ShowLastAccess)
    #>
    try {
        $config = [PSCustomObject]@{
            ServerPairs    = @($script:ServerPairs)
            ShowSizes      = $script:ShowSizes
            ShowLastAccess = $script:ShowLastAccess
        }
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $script:ConfigFile -Encoding UTF8 -Force
        Write-Log -Message "Konfiguration gespeichert: $($script:ConfigFile)"
    }
    catch {
        Write-Log -Message "Fehler beim Speichern der Konfiguration: $($_.Exception.Message)" -Type Warning
    }
}

function Show-ConfigurationDialog {
    <#
    .SYNOPSIS
        Oeffnet den Konfigurationsdialog zum Anlegen/Aendern/Entfernen der
        Profil- und Replika-Freigaben (WPF-Dialog wie TS-Profile-Manager.ps1).
        Die beiden Listen werden Index-fuer-Index zu Profilpaaren zusammengefuegt.
    .OUTPUTS
        [bool] $true, wenn die Konfiguration uebernommen wurde
    #>
    $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="TS Profile Manager - Konfiguration"
        Height="520" Width="740"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanMinimize"
        Background="#F0F0F5" FontFamily="Segoe UI"
        ShowInTaskbar="True">
    <Grid Margin="10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Column="0" Margin="0,0,5,0" BorderBrush="#BDC3C7" BorderThickness="1" CornerRadius="4" Padding="8" Background="WhiteSmoke">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="Profil-Freigaben (Primaer)" FontWeight="Bold" FontSize="11" Margin="0,0,0,4"/>
                <ListBox Grid.Row="1" x:Name="lbProfiles" FontFamily="Consolas" FontSize="11" Margin="0,0,0,4"/>
                <TextBlock Grid.Row="2" Text="Server:" FontSize="10" Margin="0,2,0,0"/>
                <TextBox Grid.Row="3" x:Name="txtProfServer" FontSize="11" Margin="0,2,0,0"/>
                <TextBlock Grid.Row="4" Text="Freigabe:" FontSize="10" Margin="0,4,0,0"/>
                <TextBox Grid.Row="5" x:Name="txtProfShare" FontSize="11" Margin="0,2,0,0"/>
                <StackPanel Grid.Row="6" Orientation="Horizontal" Margin="0,6,0,0">
                    <Button x:Name="btnProfAdd" Content="Hinzufuegen" Width="100" Height="26" Background="#2ECC71" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                    <Button x:Name="btnProfEdit" Content="Aendern" Width="80" Height="26" Background="#F39C12" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                    <Button x:Name="btnProfRemove" Content="Entfernen" Width="85" Height="26" Background="#E74C3C" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Column="1" Margin="5,0,0,0" BorderBrush="#BDC3C7" BorderThickness="1" CornerRadius="4" Padding="8" Background="WhiteSmoke">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="Profilreplika-Freigaben (Sekundaer)" FontWeight="Bold" FontSize="11" Margin="0,0,0,4"/>
                <ListBox Grid.Row="1" x:Name="lbReplicas" FontFamily="Consolas" FontSize="11" Margin="0,0,0,4"/>
                <TextBlock Grid.Row="2" Text="Server:" FontSize="10" Margin="0,2,0,0"/>
                <TextBox Grid.Row="3" x:Name="txtRepServer" FontSize="11" Margin="0,2,0,0"/>
                <TextBlock Grid.Row="4" Text="Freigabe:" FontSize="10" Margin="0,4,0,0"/>
                <TextBox Grid.Row="5" x:Name="txtRepShare" FontSize="11" Margin="0,2,0,0"/>
                <StackPanel Grid.Row="6" Orientation="Horizontal" Margin="0,6,0,0">
                    <Button x:Name="btnRepAdd" Content="Hinzufuegen" Width="100" Height="26" Background="#2ECC71" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                    <Button x:Name="btnRepEdit" Content="Aendern" Width="80" Height="26" Background="#F39C12" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,4,0"/>
                    <Button x:Name="btnRepRemove" Content="Entfernen" Width="85" Height="26" Background="#E74C3C" Foreground="White" BorderThickness="0" Cursor="Hand"/>
                </StackPanel>
            </Grid>
        </Border>

        <StackPanel Grid.Row="1" Grid.ColumnSpan="2" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,12,0,0">
            <Button x:Name="btnOK" Content="OK" Width="100" Height="32" Background="#2980B9" Foreground="White" FontWeight="Bold" BorderThickness="0" Cursor="Hand" Margin="0,0,10,0" IsDefault="True"/>
            <Button x:Name="btnCancel" Content="Abbrechen" Width="100" Height="32" Background="#95A5A6" Foreground="White" BorderThickness="0" Cursor="Hand" IsCancel="True"/>
        </StackPanel>
    </Grid>
</Window>
'@
    $reader = New-Object System.IO.StringReader($xaml)
    $xmlReader = [System.Xml.XmlReader]::Create($reader)
    $win = [Windows.Markup.XamlReader]::Load($xmlReader)

    $lbProfiles    = $win.FindName("lbProfiles")
    $txtProfServer = $win.FindName("txtProfServer")
    $txtProfShare  = $win.FindName("txtProfShare")
    $btnProfAdd    = $win.FindName("btnProfAdd")
    $btnProfEdit   = $win.FindName("btnProfEdit")
    $btnProfRemove = $win.FindName("btnProfRemove")
    $lbReplicas    = $win.FindName("lbReplicas")
    $txtRepServer  = $win.FindName("txtRepServer")
    $txtRepShare   = $win.FindName("txtRepShare")
    $btnRepAdd     = $win.FindName("btnRepAdd")
    $btnRepEdit    = $win.FindName("btnRepEdit")
    $btnRepRemove  = $win.FindName("btnRepRemove")
    $btnOK         = $win.FindName("btnOK")
    $btnCancel     = $win.FindName("btnCancel")

    # Gespeicherte Profilpaare vorladen (links = Profil, rechts = Replikat)
    foreach ($pair in $script:ServerPairs) {
        $lbProfiles.Items.Add([string]$pair.ProfilePath1) | Out-Null
        $lbReplicas.Items.Add([string]$pair.ProfilePath2) | Out-Null
    }

    $btnProfAdd.Add_Click({
        $s = $txtProfServer.Text.Trim(); $h = $txtProfShare.Text.Trim()
        if (-not $s -or -not $h) { return }
        $p = "\\$s\$h"
        if ($lbProfiles.Items -notcontains $p) { $lbProfiles.Items.Add($p) | Out-Null; $txtProfServer.Clear(); $txtProfShare.Clear(); $txtProfServer.Focus() }
    })
    $btnProfRemove.Add_Click({ if ($lbProfiles.SelectedItem) { $lbProfiles.Items.Remove($lbProfiles.SelectedItem) } })
    $btnProfEdit.Add_Click({
        $sel = $lbProfiles.SelectedItem
        if (-not $sel) { return }
        if ($sel -match '^\\\\(.+?)\\(.+)$') {
            $txtProfServer.Text = $matches[1]; $txtProfShare.Text = $matches[2]
            $lbProfiles.Items.Remove($sel)
            $txtProfServer.Focus()
        }
    })

    $btnRepAdd.Add_Click({
        $s = $txtRepServer.Text.Trim(); $h = $txtRepShare.Text.Trim()
        if (-not $s -or -not $h) { return }
        $p = "\\$s\$h"
        if ($lbReplicas.Items -notcontains $p) { $lbReplicas.Items.Add($p) | Out-Null; $txtRepServer.Clear(); $txtRepShare.Clear(); $txtRepServer.Focus() }
    })
    $btnRepRemove.Add_Click({ if ($lbReplicas.SelectedItem) { $lbReplicas.Items.Remove($lbReplicas.SelectedItem) } })
    $btnRepEdit.Add_Click({
        $sel = $lbReplicas.SelectedItem
        if (-not $sel) { return }
        if ($sel -match '^\\\\(.+?)\\(.+)$') {
            $txtRepServer.Text = $matches[1]; $txtRepShare.Text = $matches[2]
            $lbReplicas.Items.Remove($sel)
            $txtRepServer.Focus()
        }
    })

    # OK: nur vollstaendige, gleich grosse Paare uebernehmen
    $btnOK.Add_Click({
        $countPrimary = @($lbProfiles.Items).Count
        $countReplica = @($lbReplicas.Items).Count
        if ($countPrimary -eq 0 -or $countReplica -eq 0) {
            [System.Windows.MessageBox]::Show(
                "Sie muessen mindestens eine Profil-Freigabe und eine Replika-Freigabe konfigurieren.",
                "Keine Freigaben", "OK", [System.Windows.MessageBoxImage]::Warning)
            return
        }
        if ($countPrimary -ne $countReplica) {
            [System.Windows.MessageBox]::Show(
                "Die Anzahl der Profil-Freigaben ($countPrimary) muss mit der Anzahl der Replika-Freigaben ($countReplica) uebereinstimmen.`nBitte die Listen angleichen.",
                "Anzahl ungleich", "OK", [System.Windows.MessageBoxImage]::Warning)
            return
        }
        $win.DialogResult = $true
    })
    # Cancel schliesst automatisch via IsCancel

    $result = $win.ShowDialog()
    if ($result -eq $true) {
        $pathsPrimary = @($lbProfiles.Items | ForEach-Object { [string]$_ })
        $pathsReplica = @($lbReplicas.Items | ForEach-Object { [string]$_ })

        $newPairs = @()
        for ($i = 0; $i -lt $pathsPrimary.Count; $i++) {
            $path1 = $pathsPrimary[$i]
            $path2 = $pathsReplica[$i]

            # Namen eines bestehenden Paars wiederverwenden (exakt, sonst ueber einen der Pfade)
            $pairName = $null
            foreach ($old in $script:ServerPairs) {
                if ($old.ProfilePath1 -eq $path1 -and $old.ProfilePath2 -eq $path2) { $pairName = $old.Name; break }
            }
            if (-not $pairName) {
                foreach ($old in $script:ServerPairs) {
                    if ($old.ProfilePath1 -eq $path1 -or $old.ProfilePath2 -eq $path2) { $pairName = $old.Name; break }
                }
            }
            if (-not $pairName) { $pairName = "Profilpaar $($newPairs.Count + 1)" }

            $newPairs += [PSCustomObject]@{
                Name         = $pairName
                ProfilePath1 = $path1
                ProfilePath2 = $path2
            }
        }

        if ($newPairs.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Sie muessen mindestens eine Freigabe konfigurieren.", "Keine Freigaben", "OK", [System.Windows.MessageBoxImage]::Warning)
            return Show-ConfigurationDialog
        }

        $script:ServerPairs      = $newPairs
        $script:CurrentPairIndex = 0
        $script:ProfilePath1     = $newPairs[0].ProfilePath1
        $script:ProfilePath2     = $newPairs[0].ProfilePath2
        Save-Config
        return $true
    }
    return $false
}

# ============================================================
# Profilverwaltungsfunktionen
# ============================================================

function Get-ProfileListWithSizes {
    <#
    .SYNOPSIS
        Sammelt alle Profile von beiden Servern und berechnet deren Groessen
    .OUTPUTS
        Array von PSCustomObject mit Name, Size1, Size2, TotalSize, FormattedSize, Exists1, Exists2
    #>
    $profileData = @()
    $allProfiles = @()

    try {
        # Status aktualisieren
        if ($script:LabelStatus) {
            $script:LabelStatus.Text      = "Status: Sammle Profilliste von den Servern..."
            $script:LabelStatus.ForeColor = [System.Drawing.Color]::Orange
            $script:Form.Refresh()
        }

        # --- Profile von Server 1 sammeln ---
        # HashSet fuer schnelle Duplikatpruefung (auch bei 1200+ Profilen)
        $profileSet = New-Object 'System.Collections.Generic.HashSet[string]'

        if (Test-ServerConnection -Path $script:ProfilePath1) {
            Write-Log -Message "Sammle Profile von $script:ProfilePath1"
            try {
                $profiles1 = Get-ChildItem -Path $script:ProfilePath1 -Directory -ErrorAction Stop |
                             Select-Object -ExpandProperty Name
                foreach ($p in @($profiles1)) { [void]$profileSet.Add([string]$p) }
                Write-Log -Message "Server 1: $(@($profiles1).Count) Profile gefunden"
            }
            catch {
                Write-Log -Message "Fehler beim Lesen von Server 1: $($_.Exception.Message)" -Type Warning
            }
        }
        else {
            Write-Log -Message "Server 1 ($script:ProfilePath1) nicht erreichbar" -Type Warning
        }

        # --- Profile von Server 2 sammeln (Duplikate vermeiden) ---
        if (Test-ServerConnection -Path $script:ProfilePath2) {
            Write-Log -Message "Sammle Profile von $script:ProfilePath2"
            try {
                $profiles2 = Get-ChildItem -Path $script:ProfilePath2 -Directory -ErrorAction Stop |
                             Select-Object -ExpandProperty Name

                # HashSet.Add ueberschreibt Duplikate automatisch (O(1))
                foreach ($p in @($profiles2)) { [void]$profileSet.Add([string]$p) }
                Write-Log -Message "Server 2: $(@($profiles2).Count) Profile gefunden"
            }
            catch {
                Write-Log -Message "Fehler beim Lesen von Server 2: $($_.Exception.Message)" -Type Warning
            }
        }
        else {
            Write-Log -Message "Server 2 ($script:ProfilePath2) nicht erreichbar" -Type Warning
        }

        # --- Standardsortierung nach Name (A-Z) ---
        # Immer als Array erzwingen (sonst Index-Zugriff bei Einzelprofilen falsch)
        $allProfiles  = @($profileSet | Sort-Object)
        $totalCount   = $allProfiles.Count

        if ($script:ShowSizes) {
            Write-Log -Message "Berechne Groessen fuer $totalCount Profile..."
        } else {
            Write-Log -Message "Groessen-Berechnung deaktiviert (ShowSizes=false) - sammle nur Profilliste ($totalCount Profile)..."
        }

        # --- Profil-Details parallel abrufen (RunspacePool) ---
        # Groesse und Zugriffsdatum sind Netzwerk-Roundtrips. Mehrere Profile
        # gleichzeitig abrufen (bis zu 8 Threads) verkuerzt die Wartezeit
        # bei vielen Profilen (z.B. 1200) deutlich.
        $results = New-Object System.Collections.ArrayList

        if ($totalCount -gt 0) {
            $workerCode = @'
                param($Names, $Path1, $Path2, $DoSizes)
                foreach ($n in $Names) {
                    $size1    = [long]-1
                    $size2    = [long]-1
                    $access1  = $null
                    $access2  = $null
                    $exists1  = $false
                    $exists2  = $false
                    $aliasSrc = $n
                    try {
                        # Zugriffsdatum ZUERST lesen (Get-ChildItem -Recurse
                        # aktualisiert das LastAccessTime mancher Systeme)
                        $item1 = Get-Item -LiteralPath (Join-Path $Path1 $n) -Force -ErrorAction SilentlyContinue
                        $item2 = Get-Item -LiteralPath (Join-Path $Path2 $n) -Force -ErrorAction SilentlyContinue
                        $exists1 = ($null -ne $item1)
                        $exists2 = ($null -ne $item2)
                        if ($exists1) { $access1 = $item1.LastAccessTime }
                        if ($exists2) { $access2 = $item2.LastAccessTime }

                        # Alias-Quelle: VHDX-Datei im Profilordner (Root),
                        # z.B. "Profile_Mustermann.VHDX" -> "Mustermann".
                        # Nur suchen, wenn der Eintragsname nicht schon
                        # "Profile_*" lautet (sparst einen Netzwerk-Abruf).
                        if ($n -notlike 'Profile_*') {
                            if ($exists1) {
                                $vh = Get-ChildItem -LiteralPath $item1.FullName -File -Filter "*.VHDX" -ErrorAction SilentlyContinue | Select-Object -First 1
                                if ($null -ne $vh) { $aliasSrc = $vh.Name }
                            }
                            if ($aliasSrc -eq $n -and $exists2) {
                                $vh = Get-ChildItem -LiteralPath $item2.FullName -File -Filter "*.VHDX" -ErrorAction SilentlyContinue | Select-Object -First 1
                                if ($null -ne $vh) { $aliasSrc = $vh.Name }
                            }
                        }

                        if ($DoSizes) {
                            # Groessen erst NACH dem Lesen der Zugriffsdaten
                            $size1 = [long]0
                            $size2 = [long]0
                            if ($exists1) {
                                $sum1 = (Get-ChildItem -LiteralPath $item1.FullName -Recurse -File -ErrorAction SilentlyContinue |
                                         Measure-Object -Property Length -Sum).Sum
                                if ($null -ne $sum1) { $size1 = [long]$sum1 }
                            }
                            if ($exists2) {
                                $sum2 = (Get-ChildItem -LiteralPath $item2.FullName -Recurse -File -ErrorAction SilentlyContinue |
                                         Measure-Object -Property Length -Sum).Sum
                                if ($null -ne $sum2) { $size2 = [long]$sum2 }
                            }
                        }
                    }
                    catch {
                        $size1 = [long]-1
                        $size2 = [long]-1
                    }

                    [PSCustomObject]@{
                        Name        = $n
                        AliasSource = $aliasSrc
                        Size1       = $size1
                        Size2       = $size2
                        Access1     = $access1
                        Access2     = $access2
                        Exists1     = $exists1
                        Exists2     = $exists2
                    }
                }
'@

            # Chunks auf mehrere Worker verteilen (feine Chunks = guter Fortschritt)
            # Bei Netzwerk-Arbeit (SMB) lohnen sich auch auf kleinen Rechnern
            # mehrere Threads: die Wartezeit besteht aus Latenz, nicht aus CPU
            $workerCount = [Math]::Max(2, [Math]::Min(32, [int]$script:MaxLoadThreads))
            # Feine Chunks: grosse Profile blockieren nicht ein ganzes Paket
            # und der Fortschritt aktualisiert sich haeufiger
            $chunkSize   = [Math]::Max(1, [Math]::Ceiling($totalCount / ($workerCount * 12)))
            $chunks      = @()
            for ($i = 0; $i -lt $totalCount; $i += $chunkSize) {
                $end = [Math]::Min(($i + $chunkSize - 1), ($totalCount - 1))
                $chunks += , @($allProfiles[$i..$end])
            }

            $pool = [runspacefactory]::CreateRunspacePool(1, $workerCount)
            $pool.Open()
            $jobs = @()

            foreach ($chunk in $chunks) {
                $ps = [powershell]::Create()
                [void]$ps.AddScript($workerCode)
                [void]$ps.AddArgument(@($chunk))
                [void]$ps.AddArgument([string]$script:ProfilePath1)
                [void]$ps.AddArgument([string]$script:ProfilePath2)
                [void]$ps.AddArgument([bool]$script:ShowSizes)
                $ps.RunspacePool = $pool
                $jobs += [PSCustomObject]@{ PS = $ps; Handle = $ps.BeginInvoke() }
            }

            # GUI aktiv halten und Fortschritt anzeigen, bis alle Jobs fertig sind
            $doneJobs = 0
            while ($doneJobs -lt $jobs.Count) {
                if ($script:Form -and $script:Form.Visible) {
                    [System.Windows.Forms.Application]::DoEvents()
                }
                Start-Sleep -Milliseconds 120

                $doneJobs = 0
                foreach ($job in $jobs) {
                    if ($job.Handle.IsCompleted) { $doneJobs++ }
                }

                if ($script:LabelStatus) {
                    $doneProfiles = [Math]::Min($totalCount, ($doneJobs * $chunkSize))
                    $script:LabelStatus.Text = "Status: Lese Groessen/Zugriffsdaten... ($doneProfiles/$totalCount)"
                }
            }

            # Ergebnisse einsammeln
            foreach ($job in $jobs) {
                try {
                    foreach ($o in $job.PS.EndInvoke($job.Handle)) {
                        if ($null -ne $o) { [void]$results.Add($o) }
                    }
                    if ($job.PS.Streams.Error.Count -gt 0) {
                        foreach ($err in $job.PS.Streams.Error) {
                            Write-Log -Message "Parallel-Abruf: $err" -Type Warning
                        }
                    }
                }
                catch {
                    Write-Log -Message "Parallel-Abruf fehlgeschlagen: $($_.Exception.Message)" -Type Warning
                }
                finally {
                    $job.PS.Dispose()
                }
            }

            $pool.Close()
            $pool.Dispose()
            Write-Log -Message "Profil-Details abgerufen: $($results.Count)/$totalCount (parallel, $workerCount Threads)"
        }

        # --- Profil-Objekte zusammensetzen ---
        $profileData = New-Object System.Collections.ArrayList
        foreach ($r in $results) {
            try {
                if ($script:ShowSizes) {
                    # Gesamtgroesse = Maximum beider Server
                    $totalSize     = [Math]::Max([long]$r.Size1, [long]$r.Size2)
                    $formattedSize = Format-FileSize -Bytes $totalSize
                }
                else {
                    $totalSize     = [long]-1
                    $formattedSize = "-"
                }

                if ($script:ShowLastAccess) {
                    $accessCandidates = @($r.Access1, $r.Access2) | Where-Object { $_ -is [datetime] }
                    if ($accessCandidates) {
                        # Neuester Zugriff beider Server
                        $lastAccess      = $accessCandidates | Sort-Object -Descending | Select-Object -First 1
                        $formattedAccess = $lastAccess.ToString("dd.MM.yyyy HH:mm")
                    }
                    else {
                        $lastAccess      = $null
                        $formattedAccess = "-"
                    }
                }
                else {
                    # Anzeige deaktiviert -> keine Werte, Anzeige "-"
                    $lastAccess      = $null
                    $formattedAccess = "-"
                }

                [void]$profileData.Add([PSCustomObject]@{
                    Name                = $r.Name
                    Alias               = Get-ProfileAlias -Name $(if ($r.AliasSource) { $r.AliasSource } else { $r.Name })
                    Size1               = [long]$r.Size1
                    Size2               = [long]$r.Size2
                    TotalSize           = $totalSize
                    FormattedSize       = $formattedSize
                    LastAccess          = $lastAccess
                    FormattedLastAccess = $formattedAccess
                    Exists1             = [bool]$r.Exists1
                    Exists2             = [bool]$r.Exists2
                })
            }
            catch {
                Write-Log -Message "Fehler bei Profil-Objekt '$($r.Name)': $($_.Exception.Message)" -Type Warning
            }
        }

        # --- Standardsortierung nach Name (A-Z) ---
        $profileData = @($profileData | Sort-Object -Property Name)

        if ($script:ShowSizes) {
            Write-Log -Message "Groessenberechnung abgeschlossen fuer $($profileData.Count) Profile"
        } else {
            Write-Log -Message "Profilliste geladen: $($profileData.Count) Profile (ohne Groessen)"
        }
        return $profileData
    }
    catch {
        Write-Log -Message "Kritischer Fehler beim Laden der Profile: $($_.Exception.Message)" -Type Error
        return @()
    }
}

function Remove-ProfileFromServer {
    <#
    .SYNOPSIS
        Loescht ein einzelnes Profil von einem bestimmten Server
    .PARAMETER ProfileName
        Name des zu loeschenden Profils
    .PARAMETER ServerPath
        UNC-Pfad zum Server
    .OUTPUTS
        [bool] $true bei Erfolg, $false bei Fehler
    #>
    param(
        [string]$ProfileName,
        [string]$ServerPath
    )

    $profilePath = Join-Path -Path $ServerPath -ChildPath $ProfileName

    try {
        if (Test-Path -Path $profilePath) {
            Write-Log -Message "Loesche Profil '$ProfileName' von $ServerPath"

            # Erst alle Unterelemente loeschen, dann den Hauptordner
            Get-ChildItem -Path $profilePath -Recurse -Force |
                Remove-Item -Force -Recurse -ErrorAction Stop

            Remove-Item -Path $profilePath -Force -ErrorAction Stop

            Write-Log -Message "Profil '$ProfileName' erfolgreich von $ServerPath geloescht"
            return $true
        }
        else {
            Write-Log -Message "Profil '$ProfileName' existiert nicht auf $ServerPath" -Type Warning
            return $true
        }
    }
    catch {
        Write-Log -Message "Fehler beim Loeschen von '$ProfileName' auf $ServerPath : $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Remove-SelectedProfile {
    <#
    .SYNOPSIS
        Loescht das ausgewaehlte Profil von beiden Servern nach Bestaetigung
    .PARAMETER ProfileName
        Name des zu loeschenden Profils
    .PARAMETER Batch
        Ohne Bestaetigungs- und Erfolgsmeldung (fuer das Loeschen mehrerer
        Profile aus der Mehrfachauswahl); gibt $true/$false zurueck
    #>
    param(
        [string]$ProfileName,
        [switch]$Batch
    )

    try {
        if ([string]::IsNullOrWhiteSpace($ProfileName)) {
            if (-not $Batch) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Bitte waehlen Sie ein Profil aus der Liste aus.",
                    "Kein Profil ausgewaehlt",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
            }
            return $false
        }

        # Profilgroesse fuer Bestaetigung abrufen
        $profileObj = $script:ProfileData | Where-Object { $_.Name -eq $ProfileName }
        $sizeInfo   = if ($profileObj) { $profileObj.FormattedSize } else { "Unbekannt" }

        # Bestaetigungsdialog anzeigen (im Batch-Modus ueberspringen)
        if ($Batch) {
            $result = [System.Windows.Forms.DialogResult]::Yes
        }
        else {
            $confirmMsg  = "Sind Sie sicher, dass Sie das folgende Profil von BEIDEN Servern loeschen moechten?" + "`n`n"
            $confirmMsg += "Profil:  $ProfileName" + "`n"
            $confirmMsg += "Groesse: $sizeInfo" + "`n`n"
            $confirmMsg += "WARNUNG: Dieser Vorgang kann NICHT rueckgaengig gemacht werden!"

            $result = [System.Windows.Forms.MessageBox]::Show(
                $confirmMsg,
                "Profil loeschen bestaetigen",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        }

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Write-Log -Message "Beginne Loeschvorgang fuer '$ProfileName' ($sizeInfo)"

            # Status aktualisieren
            $script:LabelStatus.Text      = "Status: Loesche Profil '$ProfileName'..."
            $script:LabelStatus.ForeColor = $script:ColorDanger
            $script:Form.Refresh()

            # Von beiden Servern loeschen
            $success1 = Remove-ProfileFromServer -ProfileName $ProfileName -ServerPath $script:ProfilePath1
            $success2 = Remove-ProfileFromServer -ProfileName $ProfileName -ServerPath $script:ProfilePath2

            if ($success1 -and $success2) {
                if (-not $Batch) {
                    [System.Windows.Forms.MessageBox]::Show(
                        "Das Profil '$ProfileName' ($sizeInfo) wurde erfolgreich von beiden Servern geloescht.",
                        "Loeschvorgang erfolgreich",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                }
                Write-Log -Message "Profil '$ProfileName' erfolgreich von beiden Servern geloescht"

                # Liste neu laden (im Batch-Modus macht der Aufrufer das)
                if (-not $Batch) { Refresh-ProfileList }
                return $true
            }
            else {
                if ($Batch) {
                    Write-Log -Message "Profil '$ProfileName' nicht vollstaendig geloescht (Server1=$success1, Server2=$success2)" -Type Warning
                }
                else {
                    $errorMsg = "Das Profil '$ProfileName' wurde nicht vollstaendig geloescht:" + "`n"
                    if (-not $success1) { $errorMsg += "  [X] Fehler beim Loeschen von Server 1" + "`n" }
                    if (-not $success2) { $errorMsg += "  [X] Fehler beim Loeschen von Server 2" + "`n" }

                    [System.Windows.Forms.MessageBox]::Show(
                        $errorMsg,
                        "Loeschvorgang teilweise fehlgeschlagen",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                    )
                }
                return $false
            }
        }
        return $false
    }
    catch {
        Write-Log -Message "Unerwarteter Fehler beim Loeschvorgang: $($_.Exception.Message)" -Type Error
        if (-not $Batch) {
            [System.Windows.Forms.MessageBox]::Show(
                "Ein unerwarteter Fehler ist aufgetreten:`n$($_.Exception.Message)",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
        return $false
    }
}

function Remove-SelectedProfiles {
    <#
    .SYNOPSIS
        Loescht mehrere ausgewaehlte Profile (Mehrfachauswahl) mit einer
        gemeinsamen Bestaetigung
    .PARAMETER ProfileNames
        Array der zu loeschenden Profilnamen
    #>
    param([string[]]$ProfileNames)

    $names = @($ProfileNames | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($names.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Bitte waehlen Sie mindestens ein Profil aus der Liste aus.",
            "Kein Profil ausgewaehlt",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    # Nur ein Profil -> bewaehrten Einzel-Dialog verwenden
    if ($names.Count -eq 1) {
        Remove-SelectedProfile -ProfileName $names[0]
        return
    }

    # Gemeinsamer Bestaetigungsdialog fuer alle ausgewaehlten Profile
    $confirmMsg  = "Moechten Sie die folgenden $($names.Count) Profile von BEIDEN Servern loeschen?" + "`n`n"
    foreach ($n in $names) { $confirmMsg += "  - $n`n" }
    $confirmMsg += "`nWARNUNG: Dieser Vorgang kann NICHT rueckgaengig gemacht werden!"

    $result = [System.Windows.Forms.MessageBox]::Show(
        $confirmMsg,
        "$($names.Count) Profile loeschen bestaetigen",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    $okCount   = 0
    $failNames = @()
    foreach ($n in $names) {
        if (Remove-SelectedProfile -ProfileName $n -Batch) { $okCount++ }
        else { $failNames += $n }
    }

    Refresh-ProfileList

    $summary  = "$okCount von $($names.Count) Profilen erfolgreich geloescht."
    if ($failNames.Count -gt 0) {
        $summary += "`n`nFehlgeschlagen:"
        foreach ($f in $failNames) { $summary += "`n  - $f" }
    }
    [System.Windows.Forms.MessageBox]::Show(
        $summary,
        "Loeschvorgang abgeschlossen",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $(if ($failNames.Count -gt 0) { [System.Windows.Forms.MessageBoxIcon]::Warning } else { [System.Windows.Forms.MessageBoxIcon]::Information })
    )
    Write-Log -Message "Mehrfach-Loeschung: $okCount ok, $($failNames.Count) fehlgeschlagen"
}

# ============================================================
# Schriftart-Verwaltung
# ============================================================

function Set-ListViewFont {
    <#
    .SYNOPSIS
        Setzt die Schriftart und -groesse der ListView und aktualisiert die Anzeige
    .PARAMETER FontName
        Name der Schriftart (z.B. "Consolas", "Courier New", "Segoe UI")
    .PARAMETER FontSize
        Schriftgroesse in Punkt (7-20)
    .EXAMPLE
        Set-ListViewFont -FontName "Lucida Console" -FontSize 12
    #>
    param(
        [string]$FontName = $script:ListViewFontName,
        [int]$FontSize    = $script:ListViewFontSize
    )

    try {
        # Validierung der Schriftgroesse
        if ($FontSize -lt 7)  { $FontSize = 7 }
        if ($FontSize -gt 20) { $FontSize = 20 }

        # Pruefen ob die Schriftart existiert
        $testFont = $null
        try {
            $testFont = New-Object System.Drawing.Font($FontName, $FontSize)
            # Wenn die Schriftart nicht gefunden wird, verwendet Windows eine Ersatzschrift
            if ($testFont.Name -ne $FontName) {
                Write-Log -Message "Schriftart '$FontName' nicht gefunden, verwende '$($testFont.Name)'" -Type Warning
                $FontName = $testFont.Name
            }
        }
        catch {
            Write-Log -Message "Schriftart '$FontName' ungueltig, verwende Consolas" -Type Warning
            $FontName = "Consolas"
            $FontSize = 10
        }
        finally {
            if ($testFont) { $testFont.Dispose() }
        }

        # Neue Schriftart erstellen und zuweisen
        $newFont = New-Object System.Drawing.Font($FontName, $FontSize)
        $script:ListView.Font = $newFont

        # Globale Variablen aktualisieren
        $script:ListViewFontName = $FontName
        $script:ListViewFontSize = $FontSize

        # Spaltenbreiten anpassen (fuellen die Liste ohne Leercelle aus)
        Update-ColumnWidths

        # Font-Info-Label aktualisieren (falls vorhanden)
        if ($script:LabelFontInfo) {
            $script:LabelFontInfo.Text = "Schrift: $FontName, ${FontSize}pt"
        }

        Write-Log -Message "Schriftart geaendert: $FontName, Groesse: $FontSize pt"

        # Status aktualisieren
        if ($script:LabelStatus) {
            $script:LabelStatus.Text      = "Status: Schriftart geaendert auf '$FontName' ($FontSize pt)"
            $script:LabelStatus.ForeColor = $script:ColorAccentBlue
        }
    }
    catch {
        Write-Log -Message "Fehler beim Setzen der Schriftart: $($_.Exception.Message)" -Type Error
    }
}

# ============================================================
# ListView-Aktualisierungsfunktionen
# ============================================================

function Update-ProfileDataIndex {
    <#
    .SYNOPSIS
        Baut den Hash-Index Name -> Profilobjekt auf (O(1)-Nachschlagen
        fuer Auswahl-Status, ohne jedes Mal die ganze Liste zu durchlaufen)
    #>
    $index = @{}
    foreach ($p in $script:ProfileData) {
        if ($null -ne $p -and -not [string]::IsNullOrWhiteSpace($p.Name)) {
            $index[$p.Name] = $p
        }
    }
    $script:ProfileDataIndex = $index
}

function Update-SelectionStatus {
    <#
    .SYNOPSIS
        Aktualisiert die Statusleiste fuer die aktuelle Profilauswahl
        (Einzel- oder Mehrfachauswahl) - wird per Timer entlastet aufgerufen
    #>
    if (-not $script:LabelStatus) { return }

    $names = @($script:SelectedProfiles)
    if ($names.Count -eq 0) {
        $script:LabelStatus.Text      = "Status: Bereit"
        $script:LabelStatus.ForeColor = $script:ColorGridHeader
        return
    }

    if ($names.Count -eq 1) {
        # Einzel-Details ueber den Hash-Index (schnell)
        $profileObj = $script:ProfileDataIndex[$names[0]]
        if ($profileObj) {
            $statusParts = @()
            $statusParts += "Ausgewaehlt: $($names[0])"
            $statusParts += "Groesse: $($profileObj.FormattedSize)"
            if ($script:ShowLastAccess -and $profileObj.FormattedLastAccess -and $profileObj.FormattedLastAccess -ne "-") {
                $statusParts += "Letzter Zugriff: $($profileObj.FormattedLastAccess)"
            }

            if ($profileObj.Exists1 -and $profileObj.Exists2) {
                $statusParts += "Beide Server: OK"
            }
            elseif ($profileObj.Exists1) {
                $statusParts += "Nur Server 1: OK"
            }
            elseif ($profileObj.Exists2) {
                $statusParts += "Nur Server 2: OK"
            }

            $script:LabelStatus.Text      = "Status: " + ($statusParts -join ' - ')
            $script:LabelStatus.ForeColor = $script:ColorAccentBlue
        }
    }
    else {
        # Mehrere Zeilen ausgewaehlt: Anzahl, Gesamtgroesse und Namen
        $nameList = ($names -join ", ")
        if ($nameList.Length -gt 120) { $nameList = $nameList.Substring(0, 117) + "..." }

        $totalBytes = 0
        foreach ($n in $names) {
            $pObj = $script:ProfileDataIndex[$n]
            if ($pObj -and $pObj.TotalSize -gt 0) { $totalBytes += $pObj.TotalSize }
        }
        $totalSize = if ($totalBytes -gt 0) { "{0:N2} MB" -f ($totalBytes / 1MB) } else { "k.A." }

        $script:LabelStatus.Text      = "Status: $($names.Count) Profile ausgewaehlt ($totalSize) - $nameList"
        $script:LabelStatus.ForeColor = $script:ColorAccentBlue
    }
}

function Update-ListView {
    <#
    .SYNOPSIS
        Aktualisiert die ListView-Anzeige basierend auf Suchfilter und Sortierung
    .DESCRIPTION
        Filtert die Profildaten anhand des Suchtexts, sortiert nach aktueller
        Spalten-/Richtungseinstellung und befuellt die ListView neu.
    .PARAMETER SearchText
        Optionaler Filtertext fuer die Profilnamenssuche
    #>
    param(
        [string]$SearchText = ""
    )

    try {
        $script:ListView.BeginUpdate()
        $script:ListView.Items.Clear()

        # --- Suchfilter anwenden (sucht in Name UND Alias) ---
        $filteredData = $script:ProfileData
        if (-not [string]::IsNullOrWhiteSpace($SearchText)) {
            $searchPattern = "*$SearchText*"
            $filteredData  = $script:ProfileData | Where-Object {
                $_.Name -like $searchPattern -or $_.Alias -like $searchPattern
            }
        }

        # --- Sortierung anwenden ---
        $filteredData = Sort-ProfileData -Data $filteredData

        # --- ListView befuellen mit alternierenden Zeilenfarben ---
        $rowIndex = 0
        foreach ($profile in $filteredData) {
            try {
                # Alle 6 Spalten in EINEM Konstruktoraufruf anlegen
                # (spart 5 SubItems.Add-Aufrufe pro Zeile - bei 1200 Profilen
                #  deutlich schneller)
                $aliasText = $profile.Alias
                if ([string]::IsNullOrWhiteSpace($aliasText) -or $aliasText -eq "-") {
                    $aliasText = $profile.Name
                }

                $server1Text = if ($profile.Exists1) { "[OK] Vorhanden" } else { "[X] Fehlt" }
                $server2Text = if ($profile.Exists2) { "[OK] Vorhanden" } else { "[X] Fehlt" }
                $accessText  = $profile.FormattedLastAccess
                if ([string]::IsNullOrWhiteSpace($accessText)) { $accessText = "-" }

                # WICHTIG: ::new() mit typisiertem Array verwenden - New-Object
                # zerlegt das Argument-Array und wuerde den falschen Konstruktor
                # (mit Color-Parameter) binden.
                $cellTexts = [string[]]@($aliasText, $profile.Name, $profile.FormattedSize, $server1Text, $server2Text, $accessText)
                $item = [System.Windows.Forms.ListViewItem]::new($cellTexts)
                $item.Tag = $profile.Name

                # Subitem-Farben einzeln setzen (fuer Serverstatus-Farbcodierung)
                $item.UseItemStyleForSubItems = $false

                # Alternierende Zeilenfarben (nur am Item - die Subitems
                # erben die Farbe ueber den Fallback im OwnerDraw)
                if ($rowIndex % 2 -eq 0) {
                    $item.BackColor = $script:ColorRowNormal
                }
                else {
                    $item.BackColor = $script:ColorRowAlternate
                }

                # Farbcodierung fuer Serverstatus (Gruen=OK, Rot=Fehlt)
                $item.SubItems[3].ForeColor = if ($profile.Exists1) { $script:ColorServerOK } else { $script:ColorServerFail }
                $item.SubItems[4].ForeColor = if ($profile.Exists2) { $script:ColorServerOK } else { $script:ColorServerFail }

                # Farbcodierung fuer das Zugriffsdatum (grau wenn keine Anzeige)
                $item.SubItems[5].ForeColor = if ($accessText -eq "-") { [System.Drawing.Color]::Gray }
                                              else { [System.Drawing.Color]::FromArgb(52, 73, 94) }

                [void]$script:ListView.Items.Add($item)
                $rowIndex++
            }
            catch {
                Write-Log -Message "Fehler beim Hinzufuegen von '$($profile.Name)' zur ListView: $($_.Exception.Message)" -Type Warning
            }
        }

        $script:ListView.EndUpdate()

        # --- Spaltenbreiten anpassen (Scrollleiste beachten) ---
        Update-ColumnWidths

        # --- Profilanzahl aktualisieren ---
        $displayedCount = @($filteredData).Count
        $totalCount     = @($script:ProfileData).Count

        if ($script:LabelProfileCount) {
            if (-not [string]::IsNullOrWhiteSpace($SearchText)) {
                $script:LabelProfileCount.Text = "$displayedCount von $totalCount"
            }
            else {
                $script:LabelProfileCount.Text = "$totalCount Profile"
            }
        }

        # --- Status aktualisieren ---
        if (-not [string]::IsNullOrWhiteSpace($SearchText)) {
            $script:LabelStatus.Text      = "Status: $displayedCount von $totalCount Profilen angezeigt (Filter: '$SearchText')"
            $script:LabelStatus.ForeColor = $script:ColorAccentBlue
        }
        elseif ($script:ShowSizes) {
            $validProfiles      = $script:ProfileData | Where-Object { $_.TotalSize -ne -1 }
            $totalSize          = ($validProfiles | Measure-Object -Property TotalSize -Sum).Sum
            $totalSizeFormatted = Format-FileSize -Bytes $totalSize
            $script:LabelStatus.Text      = "Status: $totalCount Profile geladen - Gesamtgroesse: $totalSizeFormatted"
            $script:LabelStatus.ForeColor = $script:ColorSuccess
        }
        else {
            $script:LabelStatus.Text      = "Status: $totalCount Profile geladen - Groessen-Berechnung deaktiviert (ShowSizes=false)"
            $script:LabelStatus.ForeColor = $script:ColorSuccess
        }

        # --- Buttons deaktivieren (kein Profil ausgewaehlt) ---
        $script:ButtonDelete.Enabled   = $false
        $script:ButtonExplorer.Enabled = $false
        $script:SelectedProfile        = $null
        $script:SelectedProfiles       = @()
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der ListView: $($_.Exception.Message)" -Type Error
    }
}

function Sort-ProfileData {
    <#
    .SYNOPSIS
        Sortiert das Profildaten-Array anhand der aktuellen Sortiereinstellungen
    .PARAMETER Data
        Das zu sortierende Profildaten-Array
    #>
    param($Data)

    try {
        $sorted = switch ($script:SortColumn) {
            0 {
                # Sortierung nach Alias (Hilfsspalte Name als Zweitkey)
                if ($script:SortAscending) { $Data | Sort-Object -Property Alias, Name }
                else { $Data | Sort-Object -Property Alias, Name -Descending }
            }
            1 {
                # Sortierung nach Name
                if ($script:SortAscending) { $Data | Sort-Object -Property Name }
                else { $Data | Sort-Object -Property Name -Descending }
            }
            2 {
                # Sortierung nach Groesse (numerisch)
                if ($script:SortAscending) {
                    $Data | Sort-Object -Property @{Expression = { if ($_.TotalSize -eq -1) { [long]::MaxValue } else { $_.TotalSize } }}
                }
                else {
                    $Data | Sort-Object -Property @{Expression = { if ($_.TotalSize -eq -1) { -1 } else { $_.TotalSize } }} -Descending
                }
            }
            3 {
                # Sortierung nach Server 1 Status
                if ($script:SortAscending) { $Data | Sort-Object -Property Exists1, Name }
                else { $Data | Sort-Object -Property Exists1, Name -Descending }
            }
            4 {
                # Sortierung nach Server 2 Status
                if ($script:SortAscending) { $Data | Sort-Object -Property Exists2, Name }
                else { $Data | Sort-Object -Property Exists2, Name -Descending }
            }
            5 {
                # Sortierung nach letztem Zugriff (Datum, leere Werte ans Ende)
                if ($script:SortAscending) {
                    $Data | Sort-Object -Property @{Expression = { if ($null -eq $_.LastAccess) { [datetime]::MaxValue } else { $_.LastAccess } }}
                }
                else {
                    $Data | Sort-Object -Property @{Expression = { if ($null -eq $_.LastAccess) { [datetime]::MinValue } else { $_.LastAccess } }} -Descending
                }
            }
            default {
                $Data | Sort-Object -Property Name
            }
        }
        return $sorted
    }
    catch {
        Write-Log -Message "Fehler bei der Sortierung: $($_.Exception.Message)" -Type Warning
        return $Data
    }
}

function Update-ColumnHeaders {
    <#
    .SYNOPSIS
        Aktualisiert die Spaltenueberschriften mit Sortierrichtungsanzeige
    #>
    try {
        for ($i = 0; $i -lt $script:ColumnNames.Count; $i++) {
            if ($i -eq $script:SortColumn) {
                $arrow = if ($script:SortAscending) { " [^]" } else { " [v]" }
                $script:ListView.Columns[$i].Text = $script:ColumnNames[$i] + $arrow
            }
            else {
                $script:ListView.Columns[$i].Text = $script:ColumnNames[$i]
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der Spaltenueberschriften: $($_.Exception.Message)" -Type Warning
    }
}

function Update-ColumnWidthCache {
    <#
    .SYNOPSIS
        Speichert die aktuellen Spaltenbreiten in einem int-Array, damit die
        OwnerDraw-Zeichen-Handler pro Zeile keine teuren .NET-Zugriffe auf
        Columns/ColumnHeader.Width machen muessen (Performance bei vielen
        sichtbaren Zeilen)
    #>
    if (-not $script:ListView) { return }
    try {
        $n   = $script:ListView.Columns.Count
        $arr = New-Object int[] $n
        for ($i = 0; $i -lt $n; $i++) {
            $arr[$i] = $script:ListView.Columns[$i].Width
        }
        $script:ColWidthCache = $arr
    }
    catch { }
}

function Update-ColumnWidths {
    <#
    .SYNOPSIS
        Verteilt die Spaltenbreiten so auf die ListView, dass die Liste ohne
        Leercelle rechts vollstaendig gefuellt ist (dunkle Kopfzeile bis zum Rand,
        wie beim DataGrid der WPF-Version)
    #>
    try {
        if (-not $script:ListView) { return }
        if ($script:ListView.Columns.Count -eq 0) { return }

        $avail = $script:ListView.ClientSize.Width
        if ($avail -le 200) { return }

        # Vertikale Scrollleiste beruecksichtigen, falls noetig
        if ($script:ListView.Items.Count -gt 0) {
            $rowHeight = $script:ListView.Font.Height + 6
            if (($script:ListView.Items.Count * $rowHeight) -gt $script:ListView.ClientSize.Height) {
                $avail = $avail - [System.Windows.Forms.SystemInformation]::VerticalScrollBarWidth
            }
        }
        if ($avail -le 200) { return }

        $baseWidths = $script:ColumnWidths
        $baseTotal  = 0
        foreach ($w in $baseWidths) { $baseTotal += $w }
        if ($baseTotal -le 0) { return }

        $columnCount = [Math]::Min($baseWidths.Count, $script:ListView.Columns.Count)
        $sum = 0
        for ($i = 0; $i -lt $columnCount; $i++) {
            $width = [int][Math]::Round($avail * ($baseWidths[$i] / $baseTotal))
            if ($width -lt 60) { $width = 60 }
            $script:ListView.Columns[$i].Width = $width
            $sum += $width
        }

        # Ueberrest auf die letzte Spalte, damit keine Leercelle bleibt
        $rest = $avail - $sum
        if ($rest -ne 0 -and $columnCount -gt 0) {
            $lastWidth = $script:ListView.Columns[$columnCount - 1].Width + $rest
            if ($lastWidth -lt 60) { $lastWidth = 60 }
            $script:ListView.Columns[$columnCount - 1].Width = $lastWidth
        }

        # Cache fuer die Zeichen-Handler aktualisieren
        Update-ColumnWidthCache
    }
    catch {
        Write-Log -Message "Fehler beim Anpassen der Spaltenbreiten: $($_.Exception.Message)" -Type Warning
    }
}

function Update-DynamicLayout {
    <#
    .SYNOPSIS
        Positioniert alle Steuerelemente dynamisch auf die aktuelle
        ClientSize des Hauptfensters (Resize, Maximize, Minimize).
        Wird beim Start und bei jeder Groessenaenderung aufgerufen.
    #>
    try {
        if (-not $script:Form) { return }

        $cw    = $script:Form.ClientSize.Width
        $ch    = $script:Form.ClientSize.Height
        $right = $cw - 18

        # Minimiertes Fenster: nicht neu positionieren
        if ($cw -lt 700 -or $ch -lt 400) { return }

        # --- Header und Akzentbalken: volle Breite ---
        if ($script:HeaderPanel) { $script:HeaderPanel.Size = New-Object System.Drawing.Size($cw, 72) }
        if ($script:AccentBar)   { $script:AccentBar.Size   = New-Object System.Drawing.Size($cw, 4) }

        # --- Pfadzeilen: Breite bis vor die rechte Schalter-Reihe ---
        $pathWidth = ($right - 603) - 28
        if ($pathWidth -lt 200) { $pathWidth = 200 }
        if ($script:LabelServer1) { $script:LabelServer1.Width = $pathWidth }
        if ($script:LabelServer2) { $script:LabelServer2.Width = $pathWidth }

        # --- Rechte Reihe: Profilanzahl und Schalter (rechtsbuebtig) ---
        if ($script:LabelProfileCount)      { $script:LabelProfileCount.Location      = New-Object System.Drawing.Point(($right - 160), 112) }
        if ($script:ButtonFont)             { $script:ButtonFont.Location             = New-Object System.Drawing.Point(($right - 276), 110) }
        if ($script:ButtonToggleLastAccess) { $script:ButtonToggleLastAccess.Location = New-Object System.Drawing.Point(($right - 457), 110) }
        if ($script:ButtonToggleSizes)      { $script:ButtonToggleSizes.Location      = New-Object System.Drawing.Point(($right - 603), 110) }

        # --- Profilpaar-Buttons (rechts ueber den Schaltern, gleiche Formel wie New-PairButtons) ---
        if ($script:PairButtons -and $script:PairButtons.Count -gt 0) {
            $pairCount = $script:PairButtons.Count
            $pairGap   = 6
            $areaWidth = 603
            $pairWidth = [Math]::Max(80, [Math]::Floor(($areaWidth - ($pairCount - 1) * $pairGap) / $pairCount))
            for ($i = 0; $i -lt $pairCount; $i++) {
                $btnX = [int]($right - ($pairCount * $pairWidth + ($pairCount - 1) * $pairGap) + $i * ($pairWidth + $pairGap))
                $script:PairButtons[$i].Location = New-Object System.Drawing.Point($btnX, 82)
                $script:PairButtons[$i].Size     = New-Object System.Drawing.Size([int]$pairWidth, 24)
            }
        }

        # --- Toolbar rechts: Filterfeld zwischen Label und X-Button, X und Beenden rechtsbuebtig ---
        if ($script:ButtonClearSearch) { $script:ButtonClearSearch.Location = New-Object System.Drawing.Point(($right - 228), 148) }
        if ($script:ButtonExit)        { $script:ButtonExit.Location        = New-Object System.Drawing.Point(($right - 100), 147) }
        if ($script:TextBoxSearch) {
            $tbWidth = ($right - 228 - 8) - 748
            if ($tbWidth -lt 100) { $tbWidth = 100 }
            $script:TextBoxSearch.Size = New-Object System.Drawing.Size($tbWidth, 26)
        }

        # --- ListView: fuellt den Bereich bis zur Statusleiste ---
        $statusLineY = $ch - 49
        $copyY       = $ch - 17
        $listTop     = 184
        $listHeight  = ($statusLineY - 6) - $listTop
        if ($listHeight -lt 100) { $listHeight = 100 }
        if ($script:ListView) {
            $script:ListView.Location = New-Object System.Drawing.Point(18, $listTop)
            $script:ListView.Size     = New-Object System.Drawing.Size(($cw - 36), $listHeight)
        }

        # --- Statusleiste und Copyright unten ---
        if ($script:StatusLine) {
            $script:StatusLine.Location = New-Object System.Drawing.Point(0, $statusLineY)
            $script:StatusLine.Size     = New-Object System.Drawing.Size($cw, 1)
        }
        if ($script:StatusPanel) {
            $script:StatusPanel.Location = New-Object System.Drawing.Point(0, ($statusLineY + 1))
            $script:StatusPanel.Size     = New-Object System.Drawing.Size($cw, 25)
            if ($script:LabelStatus) { $script:LabelStatus.Size = New-Object System.Drawing.Size(($cw - 36), $script:StatusPanel.Height) }
        }
        if ($script:LabelCopyright) { $script:LabelCopyright.Location = New-Object System.Drawing.Point(18, $copyY) }
        if ($script:LabelFontInfo)  { $script:LabelFontInfo.Location  = New-Object System.Drawing.Point(($right - 300), $copyY) }

        # --- Spaltenbreiten an die neue Breite anpassen ---
        Update-ColumnWidths
    }
    catch {
        Write-Log -Message "Fehler beim dynamischen Layout: $($_.Exception.Message)" -Type Warning
    }
}

function Refresh-ProfileList {
    <#
    .SYNOPSIS
        Laedt die komplette Profilliste von beiden Servern neu und aktualisiert die Anzeige
    #>
    try {
        if ($script:ShowSizes) {
            Write-Log -Message "Aktualisiere Profilliste mit Groesseninformationen..."
        } else {
            Write-Log -Message "Aktualisiere Profilliste (ohne Groessen)..."
        }

        # Suchfeld leeren
        if ($script:TextBoxSearch) {
            $script:TextBoxSearch.Text = ""
        }

        # Profile laden
        $script:ProfileData = Get-ProfileListWithSizes

        # Hash-Index fuer schnelle Nachschlage-Operationen aufbauen
        Update-ProfileDataIndex

        # Sortierung auf Standard zuruecksetzen: Alias/Name aufsteigend
        $script:SortColumn    = 0
        $script:SortAscending = $true

        # ListView und Spaltenueberschriften aktualisieren
        Update-ColumnHeaders
        Update-ListView

        if (@($script:ProfileData).Count -eq 0) {
            $script:LabelStatus.Text      = "Status: Keine Profile gefunden oder Server nicht erreichbar"
            $script:LabelStatus.ForeColor = [System.Drawing.Color]::Orange
        }
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der Profilliste: $($_.Exception.Message)" -Type Error
        $script:LabelStatus.Text      = "Status: Fehler beim Laden der Profile"
        $script:LabelStatus.ForeColor = $script:ColorDanger
    }
}

# ============================================================
# GUI-Erstellung (Modernisierte Version v2.1 - ASCII-sicher)
# ============================================================

function New-StyledButton {
    <#
    .SYNOPSIS
        Erstellt einen einheitlich gestylten Button im modernen Flat-Design
    .PARAMETER Text
        Beschriftung des Buttons
    .PARAMETER Location
        Position als System.Drawing.Point
    .PARAMETER Size
        Groesse als System.Drawing.Size
    .PARAMETER BackColor
        Hintergrundfarbe des Buttons
    .PARAMETER ForeColor
        Schriftfarbe des Buttons (Standard: Weiss)
    .PARAMETER Enabled
        Ob der Button initial aktiviert ist (Standard: $true)
    #>
    param(
        [string]$Text,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor = [System.Drawing.Color]::White,
        [bool]$Enabled = $true
    )

    try {
        $button           = New-Object System.Windows.Forms.Button
        $button.Text      = $Text
        $button.Location  = $Location
        $button.Size      = $Size
        $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $button.FlatAppearance.BorderSize = 0
        $button.BackColor = $BackColor
        $button.ForeColor = $ForeColor
        $button.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $button.Cursor    = [System.Windows.Forms.Cursors]::Hand
        $button.Enabled   = $Enabled
        return $button
    }
    catch {
        Write-Log -Message "Fehler beim Erstellen des Buttons '$Text': $($_.Exception.Message)" -Type Error
        return $null
    }
}

function Initialize-GUI {
    <#
    .SYNOPSIS
        Erstellt und konfiguriert das gesamte GUI (Hauptfenster, Steuerelemente, Events)
    #>

    try {
        # ====================================================
        # Hauptfenster (Design der WPF-Version, dynamisch resizable)
        # ====================================================
        $script:Form                 = New-Object System.Windows.Forms.Form
        $script:Form.Text            = "  TS Profile Manager v2.6 - Profilverwaltung"
        $script:Form.Size            = New-Object System.Drawing.Size(1300, 740)
        $script:Form.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterScreen
        $script:Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
        $script:Form.MaximizeBox     = $true
        $script:Form.MinimumSize     = New-Object System.Drawing.Size(1150, 620)
        $script:Form.BackColor       = $script:ColorFormBackground
        $script:Form.Font            = New-Object System.Drawing.Font("Segoe UI", 9)

        # Layout-Hilfswerte (rechter Satzspiegel mit 18 px Rand)
        $cw    = $script:Form.ClientSize.Width
        $right = $cw - 18

        # ====================================================
        # Bereich 1: Header (dunkel, wie WPF-Version)
        # ====================================================
        $script:HeaderPanel           = New-Object System.Windows.Forms.Panel
        $script:HeaderPanel.Location  = New-Object System.Drawing.Point(0, 0)
        $script:HeaderPanel.Size      = New-Object System.Drawing.Size($cw, 72)
        $script:HeaderPanel.BackColor = $script:ColorHeaderBackground
        $script:Form.Controls.Add($script:HeaderPanel)

        $labelTitle           = New-Object System.Windows.Forms.Label
        $labelTitle.Text      = "TS Profile Manager"
        $labelTitle.Location  = New-Object System.Drawing.Point(22, 8)
        $labelTitle.Size      = New-Object System.Drawing.Size(600, 36)
        $labelTitle.Font      = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $labelTitle.ForeColor = [System.Drawing.Color]::White
        $labelTitle.BackColor = [System.Drawing.Color]::Transparent
        $script:HeaderPanel.Controls.Add($labelTitle)

        $labelSubtitle           = New-Object System.Windows.Forms.Label
        $labelSubtitle.Text      = "Terminalserver-Profilverwaltung mit Multi-Freigabe-Unterstuetzung"
        $labelSubtitle.Location  = New-Object System.Drawing.Point(24, 46)
        $labelSubtitle.Size      = New-Object System.Drawing.Size(700, 20)
        $labelSubtitle.Font      = New-Object System.Drawing.Font("Segoe UI", 11)
        $labelSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(180, 200, 220)   # #B4C8DC
        $labelSubtitle.BackColor = [System.Drawing.Color]::Transparent
        $script:HeaderPanel.Controls.Add($labelSubtitle)

        # Akzentbalken unter dem Header (blaue Linie wie WPF-Version)
        $script:AccentBar           = New-Object System.Windows.Forms.Panel
        $script:AccentBar.Location  = New-Object System.Drawing.Point(0, 72)
        $script:AccentBar.Size      = New-Object System.Drawing.Size($cw, 4)
        $script:AccentBar.BackColor = $script:ColorAccentBar
        $script:Form.Controls.Add($script:AccentBar)

        # ====================================================
        # Bereich 2: Pfad-Anzeige (Monospace, wie txtPaths der WPF-Version)
        # ====================================================
        $script:LabelServer1           = New-Object System.Windows.Forms.Label
        $script:LabelServer1.Text      = "Server 1 (Primaer):   $script:ProfilePath1"
        $script:LabelServer1.Location  = New-Object System.Drawing.Point(18, 86)
        $script:LabelServer1.Size      = New-Object System.Drawing.Size(620, 15)
        $script:LabelServer1.Font      = New-Object System.Drawing.Font("Consolas", 9)
        $script:LabelServer1.ForeColor = [System.Drawing.Color]::DimGray
        $script:LabelServer1.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelServer1.AutoEllipsis = $true
        $script:Form.Controls.Add($script:LabelServer1)

        $script:LabelServer2           = New-Object System.Windows.Forms.Label
        $script:LabelServer2.Text      = "Server 2 (Replikat): $script:ProfilePath2"
        $script:LabelServer2.Location  = New-Object System.Drawing.Point(18, 104)
        $script:LabelServer2.Size      = New-Object System.Drawing.Size(620, 15)
        $script:LabelServer2.Font      = New-Object System.Drawing.Font("Consolas", 9)
        $script:LabelServer2.ForeColor = [System.Drawing.Color]::DimGray
        $script:LabelServer2.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelServer2.AutoEllipsis = $true
        $script:Form.Controls.Add($script:LabelServer2)

        # ====================================================
        # Bereich 3: Schalter/Info rechts (neben den Pfadzeilen)
        # ====================================================
        $row2Y = 110

        # Profilanzahl (rechtsbündig)
        $script:LabelProfileCount           = New-Object System.Windows.Forms.Label
        $script:LabelProfileCount.Text      = "0 Profile"
        $script:LabelProfileCount.Location  = New-Object System.Drawing.Point(($right - 160), ($row2Y + 2))
        $script:LabelProfileCount.Size      = New-Object System.Drawing.Size(160, 20)
        $script:LabelProfileCount.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $script:LabelProfileCount.ForeColor = $script:ColorAccentBlue
        $script:LabelProfileCount.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelProfileCount.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $script:Form.Controls.Add($script:LabelProfileCount)

        # Schriftart-Info (rechts, unterer Rand - wird von Set-ListViewFont aktualisiert)
        $script:LabelFontInfo           = New-Object System.Windows.Forms.Label
        $script:LabelFontInfo.Text      = "Schrift: $script:ListViewFontName, $($script:ListViewFontSize)pt"
        $script:LabelFontInfo.Location  = New-Object System.Drawing.Point(($right - 300), ($script:Form.ClientSize.Height - 17))
        $script:LabelFontInfo.Size      = New-Object System.Drawing.Size(300, 16)
        $script:LabelFontInfo.Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
        $script:LabelFontInfo.ForeColor = [System.Drawing.Color]::Gray
        $script:LabelFontInfo.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelFontInfo.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $script:Form.Controls.Add($script:LabelFontInfo)

        # Button: Schriftart aendern (Windows FontDialog)
        $buttonFont = New-StyledButton -Text "Aa Schriftart" `
            -Location (New-Object System.Drawing.Point(($right - 276), $row2Y)) `
            -Size (New-Object System.Drawing.Size(110, 24)) `
            -BackColor $script:ColorFont
        $script:ButtonFont = $buttonFont
        $script:ButtonFont.add_Click({
            try {
                # Windows FontDialog oeffnen
                $fontDialog                = New-Object System.Windows.Forms.FontDialog
                $fontDialog.ShowColor      = $false
                $fontDialog.ShowEffects    = $false
                $fontDialog.MinSize        = 7
                $fontDialog.MaxSize        = 20
                $fontDialog.FixedPitchOnly = $false

                # Aktuelle Schriftart als Vorauswahl setzen
                $fontDialog.Font = New-Object System.Drawing.Font(
                    $script:ListViewFontName,
                    $script:ListViewFontSize
                )

                # Dialog anzeigen und bei OK die Schriftart uebernehmen
                if ($fontDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $selectedFont = $fontDialog.Font

                    # Schriftart setzen
                    Set-ListViewFont -FontName $selectedFont.Name -FontSize ([int]$selectedFont.Size)

                    # ListView-Inhalt neu laden damit Spaltenbreiten passen
                    $currentSearch = $script:TextBoxSearch.Text
                    if ($currentSearch -eq "Profilname eingeben zum Filtern...") {
                        $currentSearch = ""
                    }
                    Update-ListView -SearchText $currentSearch
                }
            }
            catch {
                Write-Log -Message "Fehler beim Schriftart-Dialog: $($_.Exception.Message)" -Type Warning
                [System.Windows.Forms.MessageBox]::Show(
                    "Fehler beim Aendern der Schriftart:`n$($_.Exception.Message)",
                    "Schriftart-Fehler",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
            }
        })
        $script:Form.Controls.Add($script:ButtonFont)

        # Schalter: Letzter Zugriff (AN/AUS) - wie Groessen: AN/AUS
        $script:ButtonToggleLastAccess            = New-Object System.Windows.Forms.Button
        $script:ButtonToggleLastAccess.Location   = New-Object System.Drawing.Point(($right - 457), $row2Y)
        $script:ButtonToggleLastAccess.Size       = New-Object System.Drawing.Size(175, 24)
        $script:ButtonToggleLastAccess.FlatStyle  = [System.Windows.Forms.FlatStyle]::Flat
        $script:ButtonToggleLastAccess.ForeColor  = [System.Drawing.Color]::White
        $script:ButtonToggleLastAccess.Font       = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
        $script:ButtonToggleLastAccess.Cursor     = [System.Windows.Forms.Cursors]::Hand
        $script:ButtonToggleLastAccess.Add_Click({
            Toggle-ShowLastAccess
        })
        $script:Form.Controls.Add($script:ButtonToggleLastAccess)

        # Schalter: Groessen (AN/AUS)
        $script:ButtonToggleSizes            = New-Object System.Windows.Forms.Button
        $script:ButtonToggleSizes.Location   = New-Object System.Drawing.Point(($right - 603), $row2Y)
        $script:ButtonToggleSizes.Size       = New-Object System.Drawing.Size(140, 24)
        $script:ButtonToggleSizes.FlatStyle  = [System.Windows.Forms.FlatStyle]::Flat
        $script:ButtonToggleSizes.ForeColor  = [System.Drawing.Color]::White
        $script:ButtonToggleSizes.Font       = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
        $script:ButtonToggleSizes.Cursor     = [System.Windows.Forms.Cursors]::Hand
        $script:ButtonToggleSizes.Add_Click({
            Toggle-ShowSizes
        })
        $script:Form.Controls.Add($script:ButtonToggleSizes)

        # Schalter initial anzeigen
        Update-SizeToggleButton
        Update-LastAccessToggleButton

        # Profilpaar-Buttons (einer pro Paar, rechts ueber den Schaltern)
        $script:PairButtonParent = $script:Form
        New-PairButtons

        # ====================================================
        # Bereich 4: ListView (Hauptbereich, Design des DataGrid)
        # ====================================================
        # Vertikales Layout: Liste endet ueber der Statusleiste
        $copyY       = $script:Form.ClientSize.Height - 17     # Copyright-Zeile
        $statusLineY = $script:Form.ClientSize.Height - 49     # Trennlinie ueber der Statusleiste
        $listTop     = 184
        $listHeight  = ($statusLineY - 6) - $listTop

        $script:ListView                = New-Object System.Windows.Forms.ListView
        $script:ListView.Location       = New-Object System.Drawing.Point(18, $listTop)
        $script:ListView.Size           = New-Object System.Drawing.Size(($cw - 36), $listHeight)
        $script:ListView.View           = [System.Windows.Forms.View]::Details
        $script:ListView.FullRowSelect  = $true
        $script:ListView.GridLines      = $false     # Trennlinien werden selbst gezeichnet
        $script:ListView.MultiSelect    = $true      # Mehrfachauswahl (Klick, Strg, Shift)
        $script:ListView.BackColor      = [System.Drawing.Color]::White
        $script:ListView.BorderStyle    = [System.Windows.Forms.BorderStyle]::FixedSingle

        # DoubleBuffered (nur per Reflection verfuegbar): reduziert Repaints und Flackern
        try {
            $prop = $script:ListView.GetType().GetProperty(
                "DoubleBuffered",
                [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance
            )
            if ($prop) { $prop.SetValue($script:ListView, $true) }
        }
        catch { }

        $script:Form.Controls.Add($script:ListView)

        # Schriftart aus Parameter/Variable verwenden (einstellbar ueber Button)
        $script:ListView.Font = New-Object System.Drawing.Font(
            $script:ListViewFontName,
            $script:ListViewFontSize
        )

        # Spalten hinzufuegen
        for ($i = 0; $i -lt $script:ColumnNames.Count; $i++) {
            $col = New-Object System.Windows.Forms.ColumnHeader
            $col.Text  = $script:ColumnNames[$i]
            $col.Width = $script:ColumnWidths[$i]

            # Ausrichtung: Alias/Name links, Groesse rechtsbuendig,
            # Server/Zugriff zentriert
            switch ($i) {
                2 { $col.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right }
                3 { $col.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center }
                4 { $col.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center }
                5 { $col.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center }
            }

            [void]$script:ListView.Columns.Add($col)
        }

        # Breiten-Cache auch bei manuellen Spalten-Anpassungen per Maus pflegen
        $script:ListView.add_ColumnWidthChanged({
            Update-ColumnWidthCache
        })

        # Initiale Sortierungsanzeige und Spaltenbreiten setzen
        Update-ColumnHeaders
        Update-ColumnWidths

        # ====================================================
        # OwnerDraw: dunkle Spaltenueberschriften und Zeilen
        # wie das DataGrid der WPF-Version (#34495E / Weiss,
        # alternierende Zeilenfarben, feine horizontale Linien)
        # ====================================================
        $script:ListView.OwnerDraw = $true

        $script:ListView.add_DrawColumnHeader({
            param($sender, $e)
            try {
                $bounds = $e.Bounds

                # Dunkler Hintergrund wie DataGrid-Kopfzeile
                $brush = New-Object System.Drawing.SolidBrush($script:ColorGridHeader)
                $e.Graphics.FillRectangle($brush, $bounds)
                $brush.Dispose()

                # Feine Trennlinie zwischen den Spalten
                $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 90, 110), 1)
                $e.Graphics.DrawLine($pen, ($bounds.Right - 1), $bounds.Top, ($bounds.Right - 1), $bounds.Bottom)
                $pen.Dispose()

                # Text mit der Ausrichtung der Spalte zeichnen
                $sf       = New-Object System.Drawing.StringFormat
                $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
                $textRect = New-Object System.Drawing.RectangleF(($bounds.X + 4), $bounds.Y, ($bounds.Width - 8), $bounds.Height)

                if ($e.Header.TextAlign -eq [System.Windows.Forms.HorizontalAlignment]::Right) {
                    $sf.Alignment = [System.Drawing.StringAlignment]::Far
                }
                elseif ($e.Header.TextAlign -eq [System.Windows.Forms.HorizontalAlignment]::Center) {
                    $sf.Alignment = [System.Drawing.StringAlignment]::Center
                }
                else {
                    $sf.Alignment = [System.Drawing.StringAlignment]::Near
                    $textRect = New-Object System.Drawing.RectangleF(($bounds.X + 8), $bounds.Y, ($bounds.Width - 12), $bounds.Height)
                }

                $font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
                $e.Graphics.DrawString($e.Header.Text, $font, [System.Drawing.Brushes]::White, $textRect, $sf)
                $font.Dispose()
                $sf.Dispose()
            }
            catch {
                # Zeichnen darf die GUI nicht blockieren
            }
        })

        $script:ListView.add_DrawItem({
            param($sender, $e)
            try {
                if ($null -eq $e.Item) { return }
                $item   = $e.Item
                $bounds = $e.Bounds
                if ($bounds.Height -le 0) { return }
                $selected = $item.Selected

                # --- Zentrale Zugriffe NUR EINMAL pro Zeile ---
                # (jeder .NET-Zugriff kostet in PowerShell deutlich - pro
                #  Spalte wiederholte Zugriffe waren die Hauptzeitquelle)
                $g       = $e.Graphics
                $rowW    = $sender.ClientSize.Width
                $font    = $sender.Font
                $lastIdx = $sender.Items.Count - 1
                $itemIdx = $item.Index
                $subCnt  = $item.SubItems.Count

                # Spaltenbreiten aus dem Cache (kein ColumnHeader-Zugriff;
                # Spaltenzahl fest nach Initialisierung - nur Null-Check)
                $colWArr = $script:ColWidthCache
                if ($null -eq $colWArr) {
                    Update-ColumnWidthCache
                    $colWArr = $script:ColWidthCache
                }

                # --- Zeilen-Hintergrund ueber die volle Breite ---
                $bg = if ($selected) { [System.Drawing.SystemColors]::Highlight }
                      else { $item.BackColor }
                if ($bg.A -eq 0) { $bg = $script:ColorRowNormal }

                $rowRect = [System.Drawing.Rectangle]::new(0, $bounds.Top, $rowW, $bounds.Height)
                $g.FillRectangle((Get-CachedBrush -Color $bg), $rowRect)

                # --- Alle Spaltentexte selbst zeichnen (Position aus den
                #     Spaltenbreiten, unabhaengig von e.Bounds - dadurch auch
                #     beim Maus-Hover korrekt) ---
                $top    = $bounds.Top
                $height = $bounds.Height
                $offset = 0
                for ($ci = 0; $ci -lt $colWArr.Length; $ci++) {
                    $colW = $colWArr[$ci]
                    if ($ci -ge $subCnt) { break }

                    $sub  = $item.SubItems[$ci]
                    $text = $sub.Text
                    if (-not [string]::IsNullOrEmpty($text)) {
                        $fg = if ($selected) { [System.Drawing.SystemColors]::HighlightText }
                              elseif ($ci -eq 0) { $item.ForeColor }
                              else { $sub.ForeColor }
                        if ($fg.A -eq 0) { $fg = [System.Drawing.Color]::Black }

                        switch ($ci) {
                            0 {
                                # Alias (linksbuendig)
                                $sfAlign  = "Near"
                                $textRect = [System.Drawing.RectangleF]::new(($offset + 8), $top, ($colW - 12), $height)
                            }
                            1 {
                                # Name (linksbuendig)
                                $sfAlign  = "Near"
                                $textRect = [System.Drawing.RectangleF]::new(($offset + 8), $top, ($colW - 12), $height)
                            }
                            2 {
                                # Groesse (rechtsbuendig)
                                $sfAlign  = "Far"
                                $textRect = [System.Drawing.RectangleF]::new(($offset + 4), $top, ($colW - 12), $height)
                            }
                            default {
                                # Server-Status / Letzter Zugriff (zentriert)
                                $sfAlign  = "Center"
                                $textRect = [System.Drawing.RectangleF]::new($offset, $top, $colW, $height)
                            }
                        }

                        $g.DrawString($text, $font, (Get-CachedBrush -Color $fg), $textRect, (Get-StringFormat -Alignment $sfAlign))
                    }
                    $offset += $colW
                }

                # --- Feine horizontale Trennlinie unter der Zeile ---
                if ($itemIdx -ge 0 -and $itemIdx -lt $lastIdx) {
                    $g.DrawLine((Get-SeparatorPen), 0, ($bounds.Bottom - 1), $rowW, ($bounds.Bottom - 1))
                }
            }
            catch {
                # Zeichnen darf die GUI nicht blockieren
            }
        })

        # HINWEIS: Es gibt bewusst KEINEN add_DrawSubItem-Handler mehr.
        # DrawItem zeichnet die komplette Zeile (Hintergrund + alle
        # Spaltentexte + Trennlinie). Der fruehere DrawSubItem-Handler hat
        # jede Zelle ZUSAETZLICH nochmal gezeichnet (bei 28 sichtbaren
        # Zeilen 140 Extra-Aufrufe pro Repaint -> mehrere Sekunden).

        # --- Event: Spaltenklick-Sortierung ---
        $script:ListView.add_ColumnClick({
            param($sender, $e)
            try {
                $clickedColumn = $e.Column

                if ($clickedColumn -eq $script:SortColumn) {
                    # Gleiche Spalte: Sortierrichtung umkehren
                    $script:SortAscending = -not $script:SortAscending
                }
                else {
                    # Neue Spalte: aufsteigend sortieren
                    $script:SortColumn    = $clickedColumn
                    $script:SortAscending = $true
                }

                # Spaltenueberschriften und ListView aktualisieren
                Update-ColumnHeaders

                # Aktuellen Suchtext beruecksichtigen
                $currentSearch = $script:TextBoxSearch.Text
                if ($currentSearch -eq "Profilname eingeben zum Filtern...") {
                    $currentSearch = ""
                }
                Update-ListView -SearchText $currentSearch

                $sortDir = "aufsteigend"
                if (-not $script:SortAscending) { $sortDir = "absteigend" }
                Write-Log -Message "Sortierung: $($script:ColumnNames[$script:SortColumn]) $sortDir"
            }
            catch {
                Write-Log -Message "Fehler bei Spaltensortierung: $($_.Exception.Message)" -Type Warning
            }
        })

        # --- Event: Profilauswahl in der ListView (Mehrfachauswahl) ---
        #     Der teure Status-Text wird per Timer entlastet (Debounce):
        #     bei schnellen Folgeauszwaehlungen (Shift-Bereich) aktualisiert
        #     nur der letzte Timer-Auszug die Statusleiste.
        $script:ListView.add_SelectedIndexChanged({
            try {
                # Alle ausgewaehlten Profile sammeln (Klick, Strg+Klick, Shift+Klick)
                $selectedNames = New-Object System.Collections.Generic.List[string]
                foreach ($lvItem in $script:ListView.SelectedItems) {
                    if ($null -ne $lvItem.Tag) { $selectedNames.Add($lvItem.Tag.ToString()) }
                }
                $script:SelectedProfiles = $selectedNames.ToArray()
                $script:SelectedProfile  = if ($selectedNames.Count -gt 0) { $selectedNames[0] } else { $null }

                # Buttons sofort schalten (billig), Status-Text ueber den Timer
                $script:ButtonDelete.Enabled   = ($selectedNames.Count -gt 0)
                $script:ButtonExplorer.Enabled = ($selectedNames.Count -gt 0)

                if ($script:SelectionStatusTimer) {
                    $script:SelectionStatusTimer.Stop()
                    $script:SelectionStatusTimer.Start()
                }
            }
            catch {
                Write-Log -Message "Fehler bei Profilauswahl: $($_.Exception.Message)" -Type Warning
            }
        })

        # --- Event: Doppelklick oeffnet Explorer ---
        $script:ListView.add_DoubleClick({
            try {
                if ($script:SelectedProfile) {
                    $explorerPath = Join-Path $script:ProfilePath1 $script:SelectedProfile
                    if (Test-Path $explorerPath) {
                        Start-Process explorer.exe -ArgumentList $explorerPath
                        Write-Log -Message "Explorer geoeffnet fuer: $explorerPath"
                    }
                    else {
                        # Fallback auf Server 2
                        $explorerPath = Join-Path $script:ProfilePath2 $script:SelectedProfile
                        if (Test-Path $explorerPath) {
                            Start-Process explorer.exe -ArgumentList $explorerPath
                            Write-Log -Message "Explorer geoeffnet fuer: $explorerPath (Server 2)"
                        }
                        else {
                            [System.Windows.Forms.MessageBox]::Show(
                                "Der Profilordner konnte auf keinem Server gefunden werden.",
                                "Ordner nicht gefunden",
                                [System.Windows.Forms.MessageBoxButtons]::OK,
                                [System.Windows.Forms.MessageBoxIcon]::Warning
                            )
                        }
                    }
                }
            }
            catch {
                Write-Log -Message "Fehler beim Oeffnen des Explorers: $($_.Exception.Message)" -Type Warning
            }
        })

        # ====================================================
        # Bereich 5: Button-Leiste (Toolbar, wie WPF-Version)
        # ====================================================
        $toolBarY = 144
        $btnY     = 147
        $btnH     = 28

        # Button: Profil loeschen
        $script:ButtonDelete = New-StyledButton -Text "Profil loeschen" `
            -Location (New-Object System.Drawing.Point(18, $btnY)) `
            -Size (New-Object System.Drawing.Size(115, $btnH)) `
            -BackColor $script:ColorDanger `
            -Enabled $false
        $script:ButtonDelete.add_Click({
            # Alle ausgewaehlten Profile loeschen (Einzel- oder Mehrfachauswahl)
            $names = @($script:SelectedProfiles)
            if ($names.Count -eq 0 -and $script:SelectedProfile) { $names = @($script:SelectedProfile) }
            Remove-SelectedProfiles -ProfileNames $names
        })
        $script:Form.Controls.Add($script:ButtonDelete)

        # Button: Aktualisieren
        $buttonRefresh = New-StyledButton -Text "Aktualisieren" `
            -Location (New-Object System.Drawing.Point(141, $btnY)) `
            -Size (New-Object System.Drawing.Size(115, $btnH)) `
            -BackColor $script:ColorAccentBlue
        $script:ButtonRefresh = $buttonRefresh
        $script:ButtonRefresh.add_Click({ Refresh-ProfileList })
        $script:Form.Controls.Add($script:ButtonRefresh)

        # Button: CSV-Export
        $buttonExport = New-StyledButton -Text "CSV exportieren" `
            -Location (New-Object System.Drawing.Point(264, $btnY)) `
            -Size (New-Object System.Drawing.Size(125, $btnH)) `
            -BackColor $script:ColorExport
        $script:ButtonExport = $buttonExport
        $script:ButtonExport.add_Click({
            try {
                if (@($script:ProfileData).Count -gt 0) {
                    $saveDialog          = New-Object System.Windows.Forms.SaveFileDialog
                    $saveDialog.Filter   = "CSV-Dateien (*.csv)|*.csv"
                    $saveDialog.FileName = "TS-Profile-Report_" + (Get-Date -Format 'yyyyMMdd-HHmm') + ".csv"
                    $saveDialog.Title    = "Profilbericht exportieren"

                    if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                        $script:ProfileData |
                            Select-Object Alias, Name, FormattedSize,
                                @{N='Server1';E={$_.Exists1}},
                                @{N='Server2';E={$_.Exists2}},
                                @{N='Bytes';E={$_.TotalSize}},
                                @{N='LetzterZugriff';E={ if ($_.LastAccess) { $_.LastAccess.ToString('dd.MM.yyyy HH:mm') } else { '' } }} |
                            Export-Csv -Path $saveDialog.FileName -NoTypeInformation -Encoding UTF8 -Delimiter ";"

                        [System.Windows.Forms.MessageBox]::Show(
                            "Profilbericht erfolgreich exportiert nach:`n$($saveDialog.FileName)",
                            "Export erfolgreich",
                            [System.Windows.Forms.MessageBoxButtons]::OK,
                            [System.Windows.Forms.MessageBoxIcon]::Information
                        )
                        Write-Log -Message "CSV-Export erfolgreich: $($saveDialog.FileName)"
                    }
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show(
                        "Keine Profildaten zum Exportieren vorhanden.",
                        "Keine Daten",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                }
            }
            catch {
                Write-Log -Message "Fehler beim CSV-Export: $($_.Exception.Message)" -Type Error
                [System.Windows.Forms.MessageBox]::Show(
                    "Fehler beim Exportieren: $($_.Exception.Message)",
                    "Export-Fehler",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        $script:Form.Controls.Add($script:ButtonExport)

        # Button: Im Explorer oeffnen
        $script:ButtonExplorer = New-StyledButton -Text "Im Explorer oeffnen" `
            -Location (New-Object System.Drawing.Point(397, $btnY)) `
            -Size (New-Object System.Drawing.Size(155, $btnH)) `
            -BackColor $script:ColorExplorer `
            -Enabled $false
        $script:ButtonExplorer.add_Click({
            try {
                if ($script:SelectedProfile) {
                    $explorerPath = Join-Path $script:ProfilePath1 $script:SelectedProfile
                    if (-not (Test-Path $explorerPath)) {
                        $explorerPath = Join-Path $script:ProfilePath2 $script:SelectedProfile
                    }
                    if (Test-Path $explorerPath) {
                        Start-Process explorer.exe -ArgumentList $explorerPath
                        Write-Log -Message "Explorer geoeffnet: $explorerPath"
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show(
                            "Profilordner nicht gefunden.",
                            "Nicht gefunden",
                            [System.Windows.Forms.MessageBoxButtons]::OK,
                            [System.Windows.Forms.MessageBoxIcon]::Warning
                        )
                    }
                }
            }
            catch {
                Write-Log -Message "Fehler beim Oeffnen des Explorers: $($_.Exception.Message)" -Type Warning
            }
        })
        $script:Form.Controls.Add($script:ButtonExplorer)

        # Button: Konfiguration (Freigaben bearbeiten, WPF-Dialog)
        $script:ButtonConfig = New-StyledButton -Text "Konfiguration" `
            -Location (New-Object System.Drawing.Point(560, $btnY)) `
            -Size (New-Object System.Drawing.Size(115, $btnH)) `
            -BackColor $script:ColorGridHeader
        $script:ButtonConfig.add_Click({
            try {
                $configured = Show-ConfigurationDialog
                if ($configured) {
                    Write-Log -Message "Konfiguration geaendert - Profilpaare werden neu geladen"
                    $script:CurrentPairIndex = 0
                    $script:ProfilePath1     = $script:ServerPairs[0].ProfilePath1
                    $script:ProfilePath2     = $script:ServerPairs[0].ProfilePath2
                    New-PairButtons
                    Update-PairDisplay
                    Refresh-ProfileList
                }
            }
            catch {
                Write-Log -Message "Fehler beim Oeffnen der Konfiguration: $($_.Exception.Message)" -Type Error
                [System.Windows.Forms.MessageBox]::Show(
                    "Fehler beim Oeffnen der Konfiguration:`n$($_.Exception.Message)",
                    "Konfigurations-Fehler",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        $script:Form.Controls.Add($script:ButtonConfig)

        # Trennlinie zwischen Buttons und Filter (wie Separator der WPF-Version)
        $script:ToolBarSeparator           = New-Object System.Windows.Forms.Panel
        $script:ToolBarSeparator.Location  = New-Object System.Drawing.Point(687, ($btnY + 1))
        $script:ToolBarSeparator.Size      = New-Object System.Drawing.Size(1, ($btnH - 2))
        $script:ToolBarSeparator.BackColor = [System.Drawing.Color]::FromArgb(189, 195, 199)   # #BDC3C7
        $script:Form.Controls.Add($script:ToolBarSeparator)

        # Filter-Label
        $labelSearch           = New-Object System.Windows.Forms.Label
        $labelSearch.Text      = "Filter:"
        $labelSearch.Location  = New-Object System.Drawing.Point(699, $btnY)
        $labelSearch.Size      = New-Object System.Drawing.Size(45, $btnH)
        $labelSearch.Font      = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
        $labelSearch.ForeColor = [System.Drawing.Color]::FromArgb(52, 73, 94)           # #34495E
        $labelSearch.BackColor = [System.Drawing.Color]::Transparent
        $labelSearch.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $script:Form.Controls.Add($labelSearch)

        # Such-TextBox (Echtzeit-Filter)
        $script:TextBoxSearch             = New-Object System.Windows.Forms.TextBox
        $script:TextBoxSearch.Location    = New-Object System.Drawing.Point(748, ($btnY + 1))
        $script:TextBoxSearch.Size        = New-Object System.Drawing.Size(300, 26)
        $script:TextBoxSearch.Font        = New-Object System.Drawing.Font("Segoe UI", 10)
        $script:TextBoxSearch.ForeColor   = [System.Drawing.Color]::FromArgb(80, 80, 80)
        $script:TextBoxSearch.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $script:Form.Controls.Add($script:TextBoxSearch)

        # Platzhaltertext setzen (Watermark-Effekt)
        $script:TextBoxSearch.Text      = "Profilname eingeben zum Filtern..."
        $script:TextBoxSearch.ForeColor = [System.Drawing.Color]::Silver

        # --- Event: Platzhalter entfernen bei Fokus ---
        $script:TextBoxSearch.add_GotFocus({
            if ($script:TextBoxSearch.Text -eq "Profilname eingeben zum Filtern...") {
                $script:TextBoxSearch.Text      = ""
                $script:TextBoxSearch.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
            }
        })

        # --- Event: Platzhalter wiederherstellen bei Fokusverlust ---
        $script:TextBoxSearch.add_LostFocus({
            if ([string]::IsNullOrWhiteSpace($script:TextBoxSearch.Text)) {
                $script:TextBoxSearch.Text      = "Profilname eingeben zum Filtern..."
                $script:TextBoxSearch.ForeColor = [System.Drawing.Color]::Silver
            }
        })

        # --- Event: Echtzeit-Filterung bei Texteingabe ---
        $script:TextBoxSearch.add_TextChanged({
            try {
                $searchText = $script:TextBoxSearch.Text
                # Platzhaltertext ignorieren
                if ($searchText -eq "Profilname eingeben zum Filtern...") {
                    $searchText = ""
                }
                Update-ListView -SearchText $searchText
            }
            catch {
                Write-Log -Message "Fehler bei Suchfilterung: $($_.Exception.Message)" -Type Warning
            }
        })

        # Such-Loeschen-Button
        $script:ButtonClearSearch = New-StyledButton -Text "X Loeschen" `
            -Location (New-Object System.Drawing.Point(1054, ($btnY + 1))) `
            -Size (New-Object System.Drawing.Size(80, 26)) `
            -BackColor ([System.Drawing.Color]::FromArgb(180, 180, 180))

        $script:ButtonClearSearch.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
        $script:ButtonClearSearch.add_Click({
            $script:TextBoxSearch.Text      = ""
            $script:TextBoxSearch.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
            $script:TextBoxSearch.Focus()
            Update-ListView -SearchText ""
        })
        $script:Form.Controls.Add($script:ButtonClearSearch)

        # Button: Beenden (rechtsbündig, wie WPF-Version)
        $script:ButtonExit = New-StyledButton -Text "Beenden" `
            -Location (New-Object System.Drawing.Point(($right - 100), $btnY)) `
            -Size (New-Object System.Drawing.Size(100, $btnH)) `
            -BackColor $script:ColorExit
        $script:ButtonExit.add_Click({ $script:Form.Close() })
        $script:Form.Controls.Add($script:ButtonExit)

        # ====================================================
        # Bereich 6: Statusleiste (hellgrau, wie WPF-Version)
        # ====================================================
        $script:StatusLine           = New-Object System.Windows.Forms.Panel
        $script:StatusLine.Location  = New-Object System.Drawing.Point(0, $statusLineY)
        $script:StatusLine.Size      = New-Object System.Drawing.Size($cw, 1)
        $script:StatusLine.BackColor = [System.Drawing.Color]::FromArgb(189, 195, 199)   # #BDC3C7
        $script:Form.Controls.Add($script:StatusLine)

        $script:StatusPanel           = New-Object System.Windows.Forms.Panel
        $script:StatusPanel.Location  = New-Object System.Drawing.Point(0, ($statusLineY + 1))
        $script:StatusPanel.Size      = New-Object System.Drawing.Size($cw, ($copyY - 6 - ($statusLineY + 1)))
        $script:StatusPanel.BackColor = $script:ColorStatusBarBackground                # #ECF0F1
        $script:Form.Controls.Add($script:StatusPanel)

        $script:LabelStatus           = New-Object System.Windows.Forms.Label
        $script:LabelStatus.Text      = "Status: Bereit"
        $script:LabelStatus.Location  = New-Object System.Drawing.Point(18, 0)
        $script:LabelStatus.Size      = New-Object System.Drawing.Size(($cw - 36), $script:StatusPanel.Height)
        $script:LabelStatus.Font      = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $script:LabelStatus.ForeColor = $script:ColorGridHeader                  # #34495E wie StatusBar
        $script:LabelStatus.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $script:StatusPanel.Controls.Add($script:LabelStatus)

        # ====================================================
        # Bereich 7: Copyright (unten links, wie WPF-Version)
        # ====================================================
        $script:LabelCopyright           = New-Object System.Windows.Forms.Label
        $script:LabelCopyright.Text      = "(c) 2025-2026 Rocco Ammon - TS Profile Manager v2.6"
        $script:LabelCopyright.Location  = New-Object System.Drawing.Point(18, $copyY)
        $script:LabelCopyright.Size      = New-Object System.Drawing.Size(520, 16)
        $script:LabelCopyright.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
        $script:LabelCopyright.ForeColor = [System.Drawing.Color]::Gray
        $script:LabelCopyright.BackColor = [System.Drawing.Color]::Transparent
        $script:LabelCopyright.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $script:Form.Controls.Add($script:LabelCopyright)

        # ====================================================
        # Tooltips fuer alle Buttons
        # ====================================================
        $toolTip = New-Object System.Windows.Forms.ToolTip
        $toolTip.SetToolTip($script:ButtonRefresh,        "Profilliste von beiden Servern neu laden (F5)")
        $toolTip.SetToolTip($script:ButtonDelete,        "Ausgewaehltes Profil von beiden Servern loeschen (Entf)")
        $toolTip.SetToolTip($script:ButtonExport,         "Profiluebersicht als CSV-Datei exportieren")
        $toolTip.SetToolTip($script:ButtonExplorer,      "Profilordner im Windows Explorer oeffnen (Doppelklick)")
        $toolTip.SetToolTip($script:ButtonConfig,        "Profil- und Replika-Freigaben bearbeiten (Konfigurationsmanager)")
        $toolTip.SetToolTip($script:ButtonFont,           "Schriftart und -groesse der Profilliste aendern")
        $toolTip.SetToolTip($script:ButtonToggleSizes,   "Ordner-Groessen auslesen und anzeigen (AN/AUS)")
        $toolTip.SetToolTip($script:ButtonToggleLastAccess, "Datum des letzten Zugriffs je Profilordner anzeigen (AN/AUS)")
        $toolTip.SetToolTip($script:ButtonExit,           "Programm beenden (Escape)")
        $toolTip.SetToolTip($script:TextBoxSearch,       "Profilnamen eingeben um die Liste in Echtzeit zu filtern")
        $toolTip.SetToolTip($script:ButtonClearSearch,    "Suchfeld leeren und alle Profile anzeigen")

        # ====================================================
        # Tastenkombinationen (KeyDown-Event)
        # ====================================================
        $script:Form.KeyPreview = $true
        $script:Form.add_KeyDown({
            param($sender, $e)
            try {
                # F5 = Aktualisieren
                if ($e.KeyCode -eq [System.Windows.Forms.Keys]::F5) {
                    Refresh-ProfileList
                    $e.Handled = $true
                }
                # Entf = Loeschen (nur wenn ein Profil ausgewaehlt ist)
                elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Delete -and $script:SelectedProfile) {
                    $names = @($script:SelectedProfiles)
                    if ($names.Count -eq 0 -and $script:SelectedProfile) { $names = @($script:SelectedProfile) }
                    Remove-SelectedProfiles -ProfileNames $names
                    $e.Handled = $true
                }
                # Escape = Beenden
                elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
                    $script:Form.Close()
                    $e.Handled = $true
                }
                # Strg+F = Suchfeld fokussieren
                elseif ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::F) {
                    $script:TextBoxSearch.Focus()
                    if ($script:TextBoxSearch.Text -eq "Profilname eingeben zum Filtern...") {
                        $script:TextBoxSearch.Text      = ""
                        $script:TextBoxSearch.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
                    }
                    $script:TextBoxSearch.SelectAll()
                    $e.Handled = $true
                }
            }
            catch {
                Write-Log -Message "Fehler bei Tastenkombination: $($_.Exception.Message)" -Type Warning
            }
        })

        # ====================================================
        # Dynamisches Layout: bei Groessenaenderung neu anordnen
        # ====================================================
        Update-DynamicLayout
        $script:Form.add_Resize({
            Update-DynamicLayout
        })

        # ====================================================
        # Auswahl-Status-Timer (Debounce fuer die Statusleiste)
        # ====================================================
        $script:SelectionStatusTimer           = New-Object System.Windows.Forms.Timer
        $script:SelectionStatusTimer.Interval  = 200
        $script:SelectionStatusTimer.add_Tick({
            $script:SelectionStatusTimer.Stop()
            Update-SelectionStatus
        })

        Write-Log -Message "GUI erfolgreich initialisiert"
    }
    catch {
        Write-Log -Message "Kritischer Fehler bei GUI-Erstellung: $($_.Exception.Message)" -Type Error
        throw
    }
}

# ============================================================
# Hauptprogramm
# ============================================================

function Start-ProfileManager {
    <#
    .SYNOPSIS
        Haupteinstiegspunkt - Initialisiert GUI, laedt Profile und startet die Anwendung
    .EXAMPLE
        Start-ProfileManager
    #>
    try {
        Write-Log -Message "=========================================="
        Write-Log -Message "Starte TS Profile Manager v2.6"
        Write-Log -Message "=========================================="
        Write-Log -Message "Aktives Profilpaar: $($script:ServerPairs[$script:CurrentPairIndex].Name)"
        Write-Log -Message "Server 1: $script:ProfilePath1"
        Write-Log -Message "Server 2: $script:ProfilePath2"
        Write-Log -Message "Konfigurierte Profilpaare: $($script:ServerPairs.Count)"
        foreach ($sp in $script:ServerPairs) {
            Write-Log -Message "  - '$($sp.Name)': $($sp.ProfilePath1) / $($sp.ProfilePath2)"
        }
        Write-Log -Message "Schriftart: $script:ListViewFontName, $($script:ListViewFontSize)pt"
        Write-Log -Message "Log-Datei: $script:LogFile"

        # GUI erstellen
        Initialize-GUI

        # Profilliste laden
        Refresh-ProfileList

        # GUI anzeigen (blockierend)
        Write-Log -Message "GUI wird angezeigt..."
        [void]$script:Form.ShowDialog()

        Write-Log -Message "TS Profile Manager beendet."
        Write-Log -Message "=========================================="
    }
    catch {
        Write-Log -Message "Kritischer Fehler beim Start: $($_.Exception.Message)" -Type Error
        [System.Windows.Forms.MessageBox]::Show(
            "Ein kritischer Fehler ist aufgetreten:`n$($_.Exception.Message)",
            "Kritischer Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

# Skript starten (bei Dot-Sourcing . .\Skript.ps1 wird nichts automatisch gestartet)
if ($MyInvocation.InvocationName -ne '.') {
    Start-ProfileManager
}
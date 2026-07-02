<#
.SYNOPSIS
    Terminal Server Profile Manager v1.0.0 - WPF Edition

.DESCRIPTION
    Moderne WPF-GUI zur Verwaltung von Terminalserver-Profilen auf mehreren Freigaben.
    Mit sortierbarer DataGrid, Konfigurations-Persistenz und modernem Design.

.NOTES
    Version: 1.0.0
    Author:  Rocco Ammon
#>

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

#region STA-Prüfung
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Write-Warning "Dieses Script benoetigt STA. Bitte mit -STA Parameter starten."
    exit 1
}
#endregion

#region Konfiguration
$script:ProfilePaths = @()
$script:ReplicaPaths = @()
$script:AllPaths = @()
$script:SelectedProfile = $null
$script:ProfileData = @()
$script:AllProfileData = @()
$script:SelectedFilter = "Alle"
$script:WPF_MainWindow = $null
$script:ConfigPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "TS-Profile-Manager.config.json"
#endregion

#region Hilfsfunktionen
function Write-Log {
    param([string]$Message, [ValidateSet("Info","Warning","Error")][string]$Type = "Info")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    switch ($Type) {
        "Info"    { Write-Host "[$timestamp] [Info] $Message" -ForegroundColor Green }
        "Warning" { Write-Host "[$timestamp] [Warn] $Message" -ForegroundColor Yellow }
        "Error"   { Write-Host "[$timestamp] [Err]  $Message" -ForegroundColor Red }
    }
}

function Test-ServerConnection {
    param([string]$Path)
    try { return Test-Path -Path $Path -ErrorAction Stop }
    catch {
        Write-Log -Message "Fehler beim Testen von $Path : $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Get-FolderSize {
    param([string]$Path)
    try {
        if (-not (Test-Path $Path)) { return 0 }
        return [long](Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum)
    } catch { return -1 }
}

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -eq -1)  { return "Fehler" }
    if ($Bytes -eq 0)   { return "0 B" }
    $sizes = @("B","KB","MB","GB","TB")
    $i = 0; $s = [double]$Bytes
    while ($s -ge 1024 -and $i -lt 4) { $s /= 1024; $i++ }
    return "{0:N2} {1}" -f $s, $sizes[$i]
}

function Save-Config {
    try {
        $config = @{
            ProfilePaths = $script:ProfilePaths
            ReplicaPaths = $script:ReplicaPaths
        }
        $config | ConvertTo-Json -Compress | Set-Content -Path $script:ConfigPath -Encoding UTF8 -Force
        Write-Log -Message "Konfiguration gespeichert: $($script:ConfigPath)"
    } catch {
        Write-Log -Message "Fehler beim Speichern der Konfiguration: $($_.Exception.Message)" -Type Warning
    }
}

function Load-Config {
    try {
        if (-not (Test-Path $script:ConfigPath)) { return $false }
        $config = Get-Content -Path $script:ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $script:ProfilePaths = @($config.ProfilePaths)
        $script:ReplicaPaths = @($config.ReplicaPaths)
        $script:AllPaths = $script:ProfilePaths + $script:ReplicaPaths
        Write-Log -Message "Konfiguration geladen: $($script:ConfigPath)"
        return $true
    } catch {
        Write-Log -Message "Fehler beim Laden der Konfiguration: $($_.Exception.Message)" -Type Warning
        return $false
    }
}
#endregion

#region Konfigurationsdialog (WPF)
function Show-ConfigurationDialog {
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
                    <Button x:Name="btnProfAdd" Content="Hinzufuegen" Width="120" Height="26" Background="#2ECC71" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,6,0"/>
                    <Button x:Name="btnProfRemove" Content="Entfernen" Width="120" Height="26" Background="#E74C3C" Foreground="White" BorderThickness="0" Cursor="Hand"/>
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
                    <Button x:Name="btnRepAdd" Content="Hinzufuegen" Width="120" Height="26" Background="#2ECC71" Foreground="White" BorderThickness="0" Cursor="Hand" Margin="0,0,6,0"/>
                    <Button x:Name="btnRepRemove" Content="Entfernen" Width="120" Height="26" Background="#E74C3C" Foreground="White" BorderThickness="0" Cursor="Hand"/>
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
    $btnProfRemove = $win.FindName("btnProfRemove")
    $lbReplicas    = $win.FindName("lbReplicas")
    $txtRepServer  = $win.FindName("txtRepServer")
    $txtRepShare   = $win.FindName("txtRepShare")
    $btnRepAdd     = $win.FindName("btnRepAdd")
    $btnRepRemove  = $win.FindName("btnRepRemove")
    $btnOK         = $win.FindName("btnOK")
    $btnCancel     = $win.FindName("btnCancel")

    # Gespeicherte Pfade vorladen
    if ($script:ProfilePaths.Count -gt 0) {
        foreach ($p in $script:ProfilePaths) { $lbProfiles.Items.Add($p) | Out-Null }
    } else {
        $lbProfiles.Items.Add("\\sv-lu-cxfs01\profiles$") | Out-Null
    }
    if ($script:ReplicaPaths.Count -gt 0) {
        foreach ($p in $script:ReplicaPaths) { $lbReplicas.Items.Add($p) | Out-Null }
    } else {
        $lbReplicas.Items.Add("\\sv-lu-cxfs02\profilesreplica$") | Out-Null
    }

    $btnProfAdd.Add_Click({
        $s = $txtProfServer.Text.Trim(); $h = $txtProfShare.Text.Trim()
        if (-not $s -or -not $h) { return }
        $p = "\\$s\$h"
        if ($lbProfiles.Items -notcontains $p) { $lbProfiles.Items.Add($p) | Out-Null; $txtProfServer.Clear(); $txtProfShare.Clear(); $txtProfServer.Focus() }
    })
    $btnProfRemove.Add_Click({ if ($lbProfiles.SelectedItem) { $lbProfiles.Items.Remove($lbProfiles.SelectedItem) } })

    $btnRepAdd.Add_Click({
        $s = $txtRepServer.Text.Trim(); $h = $txtRepShare.Text.Trim()
        if (-not $s -or -not $h) { return }
        $p = "\\$s\$h"
        if ($lbReplicas.Items -notcontains $p) { $lbReplicas.Items.Add($p) | Out-Null; $txtRepServer.Clear(); $txtRepShare.Clear(); $txtRepServer.Focus() }
    })
    $btnRepRemove.Add_Click({ if ($lbReplicas.SelectedItem) { $lbReplicas.Items.Remove($lbReplicas.SelectedItem) } })

    # OK schliesst mit DialogResult=$true
    $btnOK.Add_Click({ $win.DialogResult = $true })
    # Cancel schliesst automatisch via IsCancel

    $result = $win.ShowDialog()
    if ($result -eq $true) {
        $script:ProfilePaths = @($lbProfiles.Items | ForEach-Object { $_ })
        $script:ReplicaPaths = @($lbReplicas.Items | ForEach-Object { $_ })
        $script:AllPaths = $script:ProfilePaths + $script:ReplicaPaths
        Save-Config
        if ($script:AllPaths.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Sie muessen mindestens eine Freigabe konfigurieren.", "Keine Freigaben", "OK", [System.Windows.MessageBoxImage]::Warning)
            return Show-ConfigurationDialog
        }
        return $true
    }
    return $false
}
#endregion

#region Profil-Funktionen (Multi-Server)
function Get-ProfileListWithSizes {
    $profileData = @(); $allProfileNames = @()
    $pathTotals = @{}  # pro Share-Pfad die Gesamtgroesse in Bytes
    foreach ($p in $script:AllPaths) { $pathTotals[$p] = 0 }

    Write-Log -Message "Sammle Profile von $($script:AllPaths.Count) Freigabe(n)..."

    foreach ($path in $script:AllPaths) {
        if (-not (Test-ServerConnection -Path $path)) { continue }
        try {
            $names = Get-ChildItem -Path $path -Directory -ErrorAction Stop | Select-Object -ExpandProperty Name
            foreach ($n in $names) { if ($n -notin $allProfileNames) { $allProfileNames += $n } }
            Write-Log -Message "$path : $($names.Count) Profile"
        } catch { Write-Log -Message "Fehler beim Lesen von $path : $($_.Exception.Message)" -Type Warning }
    }

    $allProfileNames = $allProfileNames | Sort-Object
    $total = $allProfileNames.Count; $current = 0

    foreach ($profileName in $allProfileNames) {
        $current++
        if ($script:WPF_MainWindow) {
            $lbl = $script:WPF_MainWindow.FindName("lblStatus")
            if ($lbl) { $lbl.Content = "Status: Berechne Groessen... ($current/$total) - $profileName" }
        }

        $maxSize = 0; $existsAny = $false; $pathStatus = @()
        foreach ($path in $script:AllPaths) {
            $fullPath = Join-Path $path $profileName
            if (Test-Path $fullPath) {
                $size = Get-FolderSize -Path $fullPath
                if ($size -gt $maxSize) { $maxSize = $size }
                $existsAny = $true; $pathStatus += $path
                $pathTotals[$path] += $size
            }
        }

        $formattedSize = if ($existsAny) { Format-FileSize -Bytes $maxSize } else { "Nicht gefunden" }
        $pathList = $pathStatus -join ", "
        $profileData += [PSCustomObject]@{
            Name          = $profileName
            SizeBytes     = $maxSize
            FormattedSize = $formattedSize
            PathSummary   = if ($pathStatus.Count -gt 0) { $pathList } else { "-" }
            ShareCount    = $pathStatus.Count
        }
    }

    Write-Log -Message "Groessenberechnung abgeschlossen: $($profileData.Count) Profile"
    return @{ Profiles = $profileData; PathTotals = $pathTotals }
}

function Remove-ProfileFromServer {
    param([string]$ProfileName, [string]$ServerPath)
    $profilePath = Join-Path $ServerPath $ProfileName
    try {
        if (Test-Path $profilePath) {
            Get-ChildItem -Path $profilePath -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction Stop
            Remove-Item -Path $profilePath -Force -ErrorAction Stop
        }
        return $true
    } catch {
        Write-Log -Message "Fehler beim Loeschen von '$ProfileName' auf $ServerPath : $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Remove-SelectedProfile {
    param([string]$ProfileName)
    if ([string]::IsNullOrWhiteSpace($ProfileName)) {
        [System.Windows.MessageBox]::Show("Bitte waehlen Sie ein Profil aus.", "Kein Profil", "OK", [System.Windows.MessageBoxImage]::Warning)
        return
    }

    $obj = $script:ProfileData | Where-Object { $_.Name -eq $ProfileName }
    $sizeInfo = if ($obj) { $obj.FormattedSize } else { "Unbekannt" }

    $result = [System.Windows.MessageBox]::Show(
        "Sind Sie sicher, dass Sie das Profil '$ProfileName' ($sizeInfo) von ALLEN Freigaben loeschen mochten?`nDies kann nicht rueckgaengig gemacht werden!",
        "Profil loeschen bestaetigen", "YesNo", [System.Windows.MessageBoxImage]::Question
    )
    if ($result -ne "Yes") { return }

    try {
        $script:WPF_MainWindow.FindName("lblStatus").Content = "Status: Loesche Profil '$ProfileName' ..."
        $successCount = 0; $failCount = 0

        foreach ($path in $script:AllPaths) {
            if (Remove-ProfileFromServer -ProfileName $ProfileName -ServerPath $path) { $successCount++ }
            else { $failCount++ }
        }

        if ($failCount -eq 0) {
            [System.Windows.MessageBox]::Show("Profil '$ProfileName' ($sizeInfo) erfolgreich von allen $successCount Freigaben geloescht.", "Geloscht", "OK", [System.Windows.MessageBoxImage]::Information)
        } else {
            [System.Windows.MessageBox]::Show("Profil '$ProfileName' wurde von $successCount Freigaben geloescht.`nFehlgeschlagen: $failCount", "Teilweise geloescht", "OK", [System.Windows.MessageBoxImage]::Warning)
        }
        Refresh-ProfileList
    } catch {
        Write-Log -Message "Fehler beim Loeschvorgang: $($_.Exception.Message)" -Type Error
        [System.Windows.MessageBox]::Show("Fehler: $($_.Exception.Message)", "Fehler", "OK", [System.Windows.MessageBoxImage]::Error)
    }
}

function Update-FilterComboBox {
    $cmb = $script:WPF_MainWindow.FindName("cmbFilter")
    if (-not $cmb) { return }
    $selected = $cmb.SelectedItem
    $cmb.Items.Clear()
    $cmb.Items.Add("Alle (alle Freigaben)") | Out-Null
    foreach ($p in $script:ProfilePaths) { $cmb.Items.Add("Profil: $p") | Out-Null }
    foreach ($p in $script:ReplicaPaths) { $cmb.Items.Add("Replika: $p") | Out-Null }
    if ($selected -and $cmb.Items.Contains($selected)) { $cmb.SelectedItem = $selected }
    else { $cmb.SelectedIndex = 0; $script:SelectedFilter = $cmb.SelectedItem }
}

function Apply-Filter {
    $filter = $script:SelectedFilter
    $dg = $script:WPF_MainWindow.FindName("dgProfiles")
    if (-not $dg) { return }

    if ($filter -like "Alle*" -or [string]::IsNullOrEmpty($filter)) {
        $script:ProfileData = $script:AllProfileData
    } else {
        $prefix = if ($filter -match "^Profil: ") { $filter -replace "^Profil: ", "" }
                  elseif ($filter -match "^Replika: ") { $filter -replace "^Replika: ", "" }
                  else { $null }
        if ($prefix) {
            $script:ProfileData = $script:AllProfileData | Where-Object { $_.PathSummary -like "*$prefix*" }
        } else {
            $script:ProfileData = $script:AllProfileData
        }
    }
    $dg.ItemsSource = $null
    $dg.ItemsSource = $script:ProfileData
    Update-StatusBar
}

function Update-StatusBar {
    $filter = $script:SelectedFilter
    $filterShort = if ($filter -match "^Alle") { "Alle" } elseif ($filter -match "^Profil:\s*(.+)$") { $matches[1] } elseif ($filter -match "^Replika:\s*(.+)$") { $matches[1] } else { $filter }
    if ($script:ProfileData.Count -gt 0) {
        $valid = $script:ProfileData | Where-Object { $_.SizeBytes -ne -1 }
        $total = ($valid | Measure-Object -Property SizeBytes -Sum).Sum
        $filterInfo = if ($filterShort -ne "Alle") { " (gefiltert: $filterShort)" } else { "" }
        $status = "$($script:ProfileData.Count) Profile - Gesamt: $(Format-FileSize -Bytes $total) - $($script:AllPaths.Count) Freigabe(n)$filterInfo"
    } else {
        $status = "Keine Profile gefunden oder Freigaben nicht erreichbar"
    }
    $script:WPF_MainWindow.FindName("lblStatus").Content = "Status: $status"
}

function Refresh-ProfileList {
    try {
        $dg = $script:WPF_MainWindow.FindName("dgProfiles")
        if (-not $dg) { return }
        $dg.ItemsSource = $null
        $result = Get-ProfileListWithSizes
        $script:AllProfileData = $result.Profiles
        $pathTotals = $result.PathTotals

        # Share-Uebersicht aktualisieren
        $shareLines = @()
        foreach ($path in $script:ProfilePaths) {
            $totalBytes = $pathTotals[$path]
            $shareLines += "Profil-Freigabe: $path  =>  $(Format-FileSize -Bytes $totalBytes)"
        }
        foreach ($path in $script:ReplicaPaths) {
            $totalBytes = $pathTotals[$path]
            $shareLines += "Replika-Freigabe: $path  =>  $(Format-FileSize -Bytes $totalBytes)"
        }
        $script:WPF_MainWindow.FindName("txtShareInfo").Text = $shareLines -join "`n"

        # Filter-ComboBox befuellen und anwenden
        Update-FilterComboBox
        Apply-Filter

        $script:WPF_MainWindow.FindName("btnDelete").IsEnabled = $false
        $script:SelectedProfile = $null
    } catch {
        Write-Log -Message "Fehler beim Aktualisieren: $($_.Exception.Message)" -Type Error
        $script:WPF_MainWindow.FindName("lblStatus").Content = "Status: Fehler beim Laden"
    }
}
#endregion

#region GUI Hauptfenster (WPF)
function Initialize-GUI {
    $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="TS Profile Manager v1.0.0"
        Height="680" Width="850" MinWidth="700" MinHeight="500"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize"
        Background="#F2F2F7"
        FontFamily="Segoe UI">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="78"/>
            <RowDefinition Height="4"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="28"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#2D3E50">
            <StackPanel>
                <TextBlock Margin="22,14,0,0" FontSize="22" FontWeight="Bold" Foreground="White" Text="TS Profile Manager"/>
                <TextBlock Margin="24,4,0,0" FontSize="12" Foreground="#B4C8DC" Text="Terminalserver-Profilverwaltung mit Multi-Freigabe-Unterstuetzung"/>
            </StackPanel>
        </Border>
        <Rectangle Grid.Row="1" Fill="#3498DB"/>

        <!-- Paths + Share-Uebersicht -->
        <TextBlock Grid.Row="2" x:Name="txtPaths" Margin="18,5,18,0" FontFamily="Consolas" FontSize="11" Foreground="DimGray"/>
        <TextBlock Grid.Row="3" x:Name="txtShareInfo" Margin="18,2,18,0" FontFamily="Consolas" FontSize="11" FontWeight="Bold" Foreground="#34495E"/>

        <!-- Toolbar -->
        <StackPanel Grid.Row="4" Orientation="Horizontal" Margin="18,4,18,0" Height="32">
            <Button x:Name="btnDelete" Content="Profil loeschen" Width="120" Height="28" Background="#C0392B" Foreground="White" BorderThickness="0" Cursor="Hand"/>
            <Button x:Name="btnRefresh" Content="Aktualisieren" Width="110" Height="28" Background="#2980B9" Foreground="White" BorderThickness="0" Margin="8,0,0,0" Cursor="Hand"/>
            <Button x:Name="btnExport" Content="CSV exportieren" Width="120" Height="28" Background="#27AE60" Foreground="White" BorderThickness="0" Margin="8,0,0,0" Cursor="Hand"/>
            <Button x:Name="btnConfig" Content="Konfiguration" Width="110" Height="28" Background="#34495E" Foreground="White" BorderThickness="0" Margin="8,0,0,0" Cursor="Hand"/>
            <Separator Width="1" Background="#BDC3C7" Margin="12,2,8,2"/>
            <TextBlock Text="Filter:" VerticalAlignment="Center" FontSize="12" Foreground="#34495E" Margin="0,0,4,0"/>
            <ComboBox x:Name="cmbFilter" Width="260" Height="26" FontSize="11" FontFamily="Consolas"/>
            <Button x:Name="btnExit" Content="Beenden" Width="80" Height="28" Background="#95A5A6" Foreground="White" BorderThickness="0" Margin="8,0,0,0" Cursor="Hand" HorizontalAlignment="Right"/>
        </StackPanel>

        <!-- DataGrid -->
        <DataGrid Grid.Row="5" x:Name="dgProfiles" Margin="18,4,18,4"
                  AutoGenerateColumns="False" IsReadOnly="True"
                  CanUserSortColumns="True" CanUserAddRows="False"
                  CanUserDeleteRows="False" CanUserResizeRows="False"
                  CanUserReorderColumns="False"
                  RowHeaderWidth="0" SelectionMode="Single"
                  AlternatingRowBackground="#F5F7FA"
                  Background="White" RowBackground="White"
                  FontFamily="Consolas" FontSize="13"
                  BorderBrush="#BDC3C7" BorderThickness="1"
                  GridLinesVisibility="Horizontal"
                  HeadersVisibility="Column">
            <DataGrid.Resources>
                <Style TargetType="DataGridColumnHeader">
                    <Setter Property="Background" Value="#34495E"/>
                    <Setter Property="Foreground" Value="White"/>
                    <Setter Property="FontWeight" Value="Bold"/>
                    <Setter Property="FontFamily" Value="Segoe UI"/>
                    <Setter Property="Height" Value="32"/>
                    <Setter Property="BorderThickness" Value="0"/>
                </Style>
            </DataGrid.Resources>
            <DataGrid.Columns>
                <DataGridTextColumn Header="Profilname" Binding="{Binding Name}" Width="*" SortMemberPath="Name" MinWidth="200"/>
                <DataGridTextColumn Header="Groesse" Binding="{Binding FormattedSize}" Width="120" SortMemberPath="SizeBytes" MinWidth="90">
                    <DataGridTextColumn.ElementStyle>
                        <Style TargetType="TextBlock">
                            <Setter Property="TextAlignment" Value="Right"/>
                            <Setter Property="Margin" Value="4,0,8,0"/>
                        </Style>
                    </DataGridTextColumn.ElementStyle>
                </DataGridTextColumn>
                <DataGridTextColumn Header="Gefunden auf" Binding="{Binding PathSummary}" Width="*" SortMemberPath="ShareCount" MinWidth="120">
                    <DataGridTextColumn.ElementStyle>
                        <Style TargetType="TextBlock">
                            <Setter Property="TextAlignment" Value="Left"/>
                            <Setter Property="Margin" Value="6,0,4,0"/>
                            <Setter Property="ToolTip" Value="{Binding PathSummary}"/>
                        </Style>
                    </DataGridTextColumn.ElementStyle>
                </DataGridTextColumn>
            </DataGrid.Columns>
            <DataGrid.ContextMenu>
                <ContextMenu>
                    <MenuItem x:Name="mnuDelete" Header="Profil loeschen"/>
                </ContextMenu>
            </DataGrid.ContextMenu>
        </DataGrid>

        <!-- Status -->
        <StatusBar Grid.Row="6" Background="#ECF0F1" BorderThickness="0">
            <StatusBarItem x:Name="lblStatus" Content="Status: Bereit" Foreground="#34495E"/>
        </StatusBar>

        <!-- Copyright -->
        <TextBlock Grid.Row="7" x:Name="lblCopyright" Text="(c) 2025-2026 Rocco Ammon - TS Profile Manager v1.0.0" Margin="18,2,0,5" FontSize="9" Foreground="Gray"/>
    </Grid>
</Window>
'@

    $reader = New-Object System.IO.StringReader($xaml)
    $xmlReader = [System.Xml.XmlReader]::Create($reader)
    $script:WPF_MainWindow = [Windows.Markup.XamlReader]::Load($xmlReader)

    # Pfad-Info befuellen
    $pathLines = @()
    for ($i = 0; $i -lt $script:ProfilePaths.Count; $i++) { $pathLines += "Profil #{0}: {1}" -f ($i+1), $script:ProfilePaths[$i] }
    for ($i = 0; $i -lt $script:ReplicaPaths.Count; $i++) { $pathLines += "Replika #{0}: {1}" -f ($i+1), $script:ReplicaPaths[$i] }
    $script:WPF_MainWindow.FindName("txtPaths").Text = $pathLines -join "`n"

    # Events
    $script:WPF_MainWindow.FindName("btnDelete").Add_Click({ Remove-SelectedProfile -ProfileName $script:SelectedProfile })
    $script:WPF_MainWindow.FindName("btnRefresh").Add_Click({ Refresh-ProfileList })
    $script:WPF_MainWindow.FindName("btnExit").Add_Click({ $script:WPF_MainWindow.Close() })
    $script:WPF_MainWindow.FindName("btnConfig").Add_Click({
        $script:WPF_MainWindow.Close()
        $script:AllPaths = @()
        Start-ProfileManager
    })
    $script:WPF_MainWindow.FindName("btnExport").Add_Click({
        try {
            if ($script:ProfileData.Count -gt 0) {
                $dlg = New-Object Microsoft.Win32.SaveFileDialog
                $dlg.Filter = "CSV-Datei (*.csv)|*.csv"
                $dlg.FileName = "TS-Profile-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
                if ($dlg.ShowDialog() -eq $true) {
                    $script:ProfileData | Select-Object Name, FormattedSize, PathSummary |
                        Export-Csv -Path $dlg.FileName -NoTypeInformation -Encoding UTF8
                    [System.Windows.MessageBox]::Show("Export erfolgreich nach:`n$($dlg.FileName)", "Export", "OK", [System.Windows.MessageBoxImage]::Information)
                }
            }
        } catch {
            [System.Windows.MessageBox]::Show("Fehler beim Export: $($_.Exception.Message)", "Fehler", "OK", [System.Windows.MessageBoxImage]::Error)
        }
    })

    # DataGrid SelectionChanged
    $script:WPF_MainWindow.FindName("dgProfiles").Add_SelectionChanged({
        $dg = $script:WPF_MainWindow.FindName("dgProfiles")
        if ($dg.SelectedItem) {
            $name = $dg.SelectedItem.Name
            if ($name) {
                $script:SelectedProfile = $name
                $script:WPF_MainWindow.FindName("btnDelete").IsEnabled = $true
                $obj = $script:ProfileData | Where-Object { $_.Name -eq $name }
                if ($obj) {
                    $shareCount = $obj.ShareCount
                    $script:WPF_MainWindow.FindName("lblStatus").Content = "Ausgewaehlt: $name | Grosse: $($obj.FormattedSize) | auf $shareCount Freigabe(n)"
                }
                return
            }
        }
        $script:SelectedProfile = $null
        $script:WPF_MainWindow.FindName("btnDelete").IsEnabled = $false
    })

    # Doppelklick = loeschen
    $script:WPF_MainWindow.FindName("dgProfiles").Add_MouseDoubleClick({
        if ($script:SelectedProfile) { Remove-SelectedProfile -ProfileName $script:SelectedProfile }
    })

    # Filter-Combobox
    $script:WPF_MainWindow.FindName("cmbFilter").Add_SelectionChanged({
        $cmb = $script:WPF_MainWindow.FindName("cmbFilter")
        if ($cmb.SelectedItem) {
            $script:SelectedFilter = $cmb.SelectedItem
            Apply-Filter
        }
    })

    # Rechtsklick = Zeile auswaehlen + Kontextmenue
    $dg = $script:WPF_MainWindow.FindName("dgProfiles")
    $dg.Add_PreviewMouseRightButtonDown({
        try {
            $hit = $_.OriginalSource
            while ($hit -and $hit.GetType().Name -ne "DataGridRow") { $hit = [System.Windows.Media.VisualTreeHelper]::GetParent($hit) }
            if ($hit -and $hit.GetType().Name -eq "DataGridRow") {
                $hit.IsSelected = $true
                $name = $hit.Item.Name
                if ($name) {
                    $script:SelectedProfile = $name
                    $script:WPF_MainWindow.FindName("btnDelete").IsEnabled = $true
                    $obj = $script:ProfileData | Where-Object { $_.Name -eq $name }
                    if ($obj) {
                        $script:WPF_MainWindow.FindName("lblStatus").Content = "Ausgewaehlt: $name | Grosse: $($obj.FormattedSize) | $($obj.PathSummary)"
                    }
                }
            }
        } catch { Write-Log -Message "Fehler bei Rechtsklick: $($_.Exception.Message)" -Type Error }
    })

    # Kontextmenue "Loeschen"
    $script:WPF_MainWindow.FindName("mnuDelete").Add_Click({
        if ($script:SelectedProfile) { Remove-SelectedProfile -ProfileName $script:SelectedProfile }
    })
}

#endregion

#region Hauptprogramm
function Start-ProfileManager {
    try {
        Write-Log -Message "TS Profile Manager v2.0 WPF gestartet"

        # Gespeicherte Konfiguration laden
        Load-Config

        if ($script:AllPaths.Count -eq 0) {
            $configured = Show-ConfigurationDialog
            if (-not $configured) {
                Write-Log -Message "Abbruch durch Benutzer" -Type Warning
                return
            }
        }

        Write-Log -Message "Profil-Freigaben: $($script:ProfilePaths -join ', ')"
        Write-Log -Message "Replika-Freigaben: $($script:ReplicaPaths -join ', ')"

        Initialize-GUI
        Refresh-ProfileList

        [void]$script:WPF_MainWindow.ShowDialog()
        Write-Log -Message "Beendet"
    } catch {
        Write-Log -Message "Kritischer Fehler: $($_.Exception.Message)" -Type Error
        [System.Windows.MessageBox]::Show("Kritischer Fehler:`n$($_.Exception.Message)", "Fehler", "OK", [System.Windows.MessageBoxImage]::Error)
    }
}

Start-ProfileManager
#endregion

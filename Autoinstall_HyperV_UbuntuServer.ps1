<# 
Installskript via Powershell um den Bums automatisch einrichten zu lassen, geht schneller und einfacher...
12.09.2024 - V1.2
#>

# ===========================================  Step 1: - Hyper V Konfiguration ===========================================

#Set-ExecutionPolicy Bypass -Scope Process -Force
#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force



$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
$delay_msg = Start-Sleep -Seconds 5

if ($feature.State -eq "Enabled") {
    Write-Host "Hyper-V is already installed."
    $delay_msg
} elseif ($feature.State -eq "Disabled") {
    Write-Host "Hyper-V is not installed. Installing now..."
    $test = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

    if ($test.RestartNeeded) {
        Write-Host "A restart is needed to complete the installation. Please restart your system and rerun the script."
        $delay_msg
        exit
    } else {
        Write-Host "Hyper-V is successfully enabled."
        $delay_msg
    }
} else {
    Write-Host "Hyper-V installation status is unclear. Please check manually."
    $delay_msg
    exit
}

# ===========================================  Step 2:  - Download Ubuntu Server ===========================================

$isoUrl = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
$outputPath = "C:\temp\ubuntu-20.04-live-server-amd64.iso"

# Funktion, um die geschätzte Größe der ISO-Datei zu erhalten (optional)
function Get-EstimatedISOFileSize {
    # Die Größe könnte durch Recherchen auf der Download-Seite geschätzt werden
    return 1000MB # Beispielgröße in MB, ersetze dies durch die tatsächliche Größe
}

if (Test-Path -Path $outputPath) {
    Write-Host "Die Datei existiert bereits am angegebenen Speicherort."
    $delay_msg
    # Optional: Überprüfe die Größe der bestehenden Datei
    $expectedSize = Get-EstimatedISOFileSize
    $actualSize = (Get-Item -Path $outputPath).length

    if ($actualSize -lt $expectedSize) {
        Write-Host "Die heruntergeladene Datei scheint unvollständig zu sein. Erneuter Download wird versucht..."
        $delay_msg
        Remove-Item -Path $outputPath
        # Fortfahren mit dem Download
    } else {
        Write-Host "Die Datei existiert bereits und scheint vollständig zu sein."
        $delay_msg
        # Weiter mit der VM-Erstellung
    }
}

if (-not (Test-Path -Path $outputPath)) {
    Write-Host "Lade Ubuntu Server ISO herunter..."
    
    try {
        # Download der ISO-Datei
        Invoke-WebRequest -Uri $isoUrl -OutFile $outputPath
        Write-Host "Download abgeschlossen! Die ISO wurde unter $outputPath gespeichert."
        $delay_msg
    } catch {
        Write-Host "Fehler beim Herunterladen der Datei: $_"
        $delay_msg
        exit
    }
}

# ===========================================  Step 3: Erstellung der VM in Hyper-V Umgebung ===========================================

$vmName = "UbuntuServer"
$vmPath = "C:\Hyper-V\UbuntuServer"

# Prüfe, ob der Ordner bereits existiert
if (Test-Path -Path $vmPath) {
    Write-Host "Der Ordner $vmPath existiert bereits. Lösche den Ordner..."
    Remove-Item -Path $vmPath -Recurse -Force
    Write-Host "Ordner $vmPath wurde gelöscht. Bitte auch VM in Hyper-V löschen um das Rollout neu durchzuführen!"
    Start-Sleep -Seconds 5
}

try {
    New-Item -Path $vmPath -ItemType Directory -Force
    New-VM -Name $vmName -MemoryStartupBytes 2GB -Generation 1 -NewVHDPath "$vmPath\UbuntuServer.vhdx" -NewVHDSizeBytes 60GB
    Set-VMProcessor -VMName $vmName -Count 4
    Add-VMNetworkAdapter -VMName $vmName -SwitchName "Default Switch"
    Set-VMDvdDrive -VMName $vmName -Path $outputPath

    # Starten der VM
    Start-VM -Name $vmName
    Write-Host "VM $vmName wurde erstellt und gestartet!"
    $delay_msg
} catch {
    Write-Host "Fehler beim Erstellen oder Starten der VM: $_"
    $delay_msg
}

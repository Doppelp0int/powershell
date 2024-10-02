<# 
Installskript via Powershell um den Bums automatisch einrichten zu lassen, geht schneller und einfacher...
12.09.2024 - V1.6
#>

# ===========================================  Step 1: - Hyper V Konfiguration ===========================================

Set-ExecutionPolicy Bypass -Scope Process -Force
$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

if ($feature.State -eq "Enabled") {
    Write-Host "Hyper-V is already installed."
    Start-Sleep -Seconds 5
} elseif ($feature.State -eq "Disabled") {
    Write-Host "Hyper-V is not installed. Installing now..."
    $test = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

    if ($test.RestartNeeded) {
        Write-Host "A restart is needed to complete the installation. Please restart your system and rerun the script."
        Start-Sleep -Seconds 10
        exit
    } else {
        Write-Host "Hyper-V is successfully enabled."
        Start-Sleep -Seconds 5
    }
} else {
    Write-Host "Hyper-V installation status is unclear. Please check manually."
    Start-Sleep -Seconds 5
    exit
}

# ===========================================  Step 2:  - Download Ubuntu Server ===========================================

$isoUrl = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
$outputPath = "C:\temp\ubuntu-20.04-live-server-amd64.iso"

function Get-EstimatedISOFileSize {
    return 1000MB # Beispielgröße in MB, ersetze dies durch die tatsächliche Größe
}

if (Test-Path -Path $outputPath) {
    Write-Host "Die Datei existiert bereits am angegebenen Speicherort."
    Start-Sleep -Seconds 5
    $expectedSize = Get-EstimatedISOFileSize
    $actualSize = (Get-Item -Path $outputPath).length

    if ($actualSize -lt $expectedSize) {
        Write-Host "Die heruntergeladene Datei scheint unvollständig zu sein. Erneuter Download wird versucht..."
        Start-Sleep -Seconds 5
        Remove-Item -Path $outputPath
    } else {
        Write-Host "Die Datei existiert bereits und scheint vollständig zu sein."
        Start-Sleep -Seconds 5
    }
}

if (-not (Test-Path -Path $outputPath)) {
    Write-Host "Lade Ubuntu Server ISO herunter..."
    
    try {
        Invoke-WebRequest -Uri $isoUrl -OutFile $outputPath
        Write-Host "Download abgeschlossen! Die ISO wurde unter $outputPath gespeichert."
        Start-Sleep -Seconds 5
    } catch {
        Write-Host "Fehler beim Herunterladen der Datei: $_"
        Start-Sleep -Seconds 5
        exit
    }
}

# ===========================================  Step 3: Prüfen und Löschen der vorhandenen VM und des Verzeichnisses ===========================================

$vmName = "UbuntuServer"
$vmPath = "C:\Hyper-V\UbuntuServer"

# Prüfe, ob die VM bereits existiert
$existingVM = Get-VM -Name $vmName -ErrorAction SilentlyContinue

if ($existingVM) {
    Write-Host "Die VM $vmName existiert bereits. Lösche die VM..."
    
    # Stoppe die VM, falls sie läuft
    if ($existingVM.State -eq 'Running') {
        Stop-VM -Name $vmName -Force
        Write-Host "VM $vmName wurde gestoppt."
        Start-Sleep -Seconds 5
    }

    # Lösche die VM
    Remove-VM -Name $vmName -Force
    Write-Host "VM $vmName wurde gelöscht."
    Start-Sleep -Seconds 5
}

# Prüfe, ob der Ordner bereits existiert
if (Test-Path -Path $vmPath) {
    Write-Host "Der Ordner $vmPath existiert bereits. Lösche den Ordner..."
    Remove-Item -Path $vmPath -Recurse -Force
    Write-Host "Ordner $vmPath wurde gelöscht."
    Start-Sleep -Seconds 5
}

# ===========================================  Step 4: Erstellung der VM in Hyper-V Umgebung ===========================================
try {
    New-Item -Path $vmPath -ItemType Directory -Force
    New-VM -Name $vmName -MemoryStartupBytes 2GB -Generation 1 -NewVHDPath "$vmPath\UbuntuServer.vhdx" -NewVHDSizeBytes 60GB
    Add-VMNetworkAdapter -VMName $vmName -SwitchName "Default Switch"
    Set-VMDvdDrive -VMName $vmName -Path $outputPath
    Set-VMProcessor -VMName $vmName -Count 4
    
    # Starte die VM
    Start-VM -Name $vmName
    Write-Host "VM $vmName wurde erstellt und gestartet!"
    Start-Sleep -Seconds 5
} catch {
    Write-Host "Fehler beim Erstellen oder Starten der VM: $_"
    Start-Sleep -Seconds 5
}

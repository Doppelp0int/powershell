# Prüfe, ob das Skript als Administrator ausgeführt wird
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Funktion zum Prüfen, ob WSL aktiviert ist
function Check-WSL-Installation {
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    if ($wslFeature.State -eq "Enabled") {
        Write-Host "INFO: WSL ist aktiviert." -Fore Green
    } else {
        Write-Host "INFO: WSL ist nicht aktiviert." -Fore Red
        Install-WSL
    }
}


# Funktion zur deinstallation bei problemen.
function Uninstall-WSL{
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    wsl --uninstall
    wsl --unregister ubuntu
}

# Funktion zur Installation von WSL
function Install-WSL {
    Write-Host "INFO: WSL wird installiert..." -Fore Yellow
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart


    # Setze WSL 2 als Standard
        Start-Process "wsl.exe" -ArgumentList "--set-default-version 2" -NoNewWindow
            Write-Host "INFO: WSL wird aktuallisiert..." -Fore Yellow
        Start-Process "wsl.exe" -ArgumentList "--update" -NoNewWindow -Wait
         Start-Sleep -Seconds 20

    Write-Host "INFO: WSL wurde erfolgreich installiert." -Fore Green
}

# Funktion zur Installation von Ubuntu ohne Benutzererstellung
function Install-Ubuntu {

    Write-Host "INFO: Ubuntu wird installiert... bitte warten..." -Fore Yellow

    Start-Process "wsl.exe" -ArgumentList "--install --web-download -d Ubuntu " -NoNewWindow
    Start-Sleep -Seconds 5
    wsl --terminate "Ubuntu"
    # Warten, bis Ubuntu installiert wurde
    Start-Sleep -Seconds 5


    do {
    # Befehl ausführen
    $output = wsl -l | Where-Object { $_.Replace("`0","") -match '^Ubuntu' }
    
    # Prüfen, ob ein Ergebnis vorhanden ist
    if ($output) {
        Write-Host "Ubuntu gefunden. Skript wird fortgesetzt."
        break # Schleife verlassen, wenn Bedingung erfüllt ist
    }
    
    # Warten für 3 Sekunden
    Start-Sleep -Seconds 5

} while ($true)
    # Download des Installationsskripts von GitHub und Ausführung
    $scriptUrl = "https://raw.githubusercontent.com/Doppelp0int/batch/refs/heads/main/WSL_install_Docker.sh"
    $outputPath = "C:\temp\WSL_install_Docker.sh"
    Write-Host "INFO: Download des Installationsskripts von GitHub..." -Fore Yellow
    Invoke-WebRequest -Uri $scriptUrl -OutFile $outputPath

    # Führe das Skript in der WSL-Umgebung aus
    #$folder = "/mnt/c/temp" # Pfad in der WSL-Umgebung
    #wsl bash -c "bash $outputPath"
    wsl -u root bash -c "cd /mnt/c/temp && bash ./WSL_install_Docker.sh"
    Write-Host "INFO: Installationsskript erfolgreich ausgeführt." -Fore Green

    # Bereinige das Skript nach der Ausführung
    try {
        Remove-Item -Path $outputPath -Force
    } catch {
        Write-Host "ERROR: Fehler beim Löschen des Skripts $outputPath." -Fore Red
    }
}

# Hauptlogik des Skripts
try {
    # Überprüfen, ob WSL installiert ist
    if (-not (Check-WSL-Installation)) {
        Install-WSL
    } else {
        Write-Host "CHECK: WSL ist bereits aktiviert." -Fore Yellow
    }

    # Überprüfen, ob WSL ordnungsgemäß funktioniert
    try {
        wsl.exe --list --online | Out-Null
        Write-Host "CHECK: WSL funktioniert einwandfrei." -Fore Green
    } catch {
        Write-Host "CHECK: Problem mit WSL erkannt. Deinstallation wird durchgeführt." -Fore Red
        Uninstall-WSL
        Install-WSL
    }

    # Installiere und konfiguriere Ubuntu
    Install-Ubuntu
    Start-Sleep -Seconds 2
    Write-Host "INFO: Ubuntu wurde erfolgreich installiert und eingerichtet." -Fore Green
    # Öffne den Portainer-Link
    Write-Host "READY: Öffne Portainer...https://localhost:9443/#!/init/admin -Installer wird geschlossen......" -Fore Green
    Start-Process "https://localhost:9443/#!/init/admin"
    Start-Sleep -Seconds 5
    Exit
} catch {
    Write-Host "ERROR: Ein unerwarteter Fehler ist aufgetreten." -Fore Red
    throw $_
}

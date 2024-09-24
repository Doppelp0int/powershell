# Prüfe, ob das Skript als Administrator ausgeführt wird
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "`n"
Write-Host "                    -------------------------------------------------            " -ForegroundColor Cyan
Write-Host "                    |                                               |            " -ForegroundColor Cyan
Write-Host "                    |               WSL Installer                   |            " -ForegroundColor Cyan
Write-Host "                    |          Version 1.4 -> 24.09.2024            |            " -ForegroundColor Cyan
Write-Host "                    |                                               |            " -ForegroundColor Cyan
Write-Host "                    |                                               |            " -ForegroundColor Cyan
Write-Host "                    -------------------------------------------------            " -ForegroundColor Cyan
Write-Host "`n"



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
	Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
	Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
    wsl --uninstall
    wsl --unregister ubuntu
}
# Funktion zur Installation von WSL
function Install-WSL {
    Write-Host "INFO: WSL wird installiert..." -Fore Yellow
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart | Out-Null
	Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null
    # Setze WSL 2 als Standard
        Start-Process "wsl.exe" -ArgumentList "--set-default-version 2" -NoNewWindow > $null
            Write-Host "INFO: WSL wird aktuallisiert..." -Fore Yellow
        Start-Process "wsl.exe" -ArgumentList "--update" -NoNewWindow -Wait | Out-Null
         Start-Sleep -Seconds 20

    Write-Host "INFO: WSL wurde erfolgreich installiert." -Fore Green
}
# Funktion zur Installation von Ubuntu ohne Benutzererstellung
function Install-Ubuntu {
    Write-Host "INFO: Ubuntu wird installiert... bitte warten..." -Fore Yellow

    Start-Process "wsl.exe" -ArgumentList "--install --web-download -d Ubuntu" -NoNewWindow > $null
    Start-Sleep -Seconds 5
    wsl --terminate "Ubuntu" | Out-Null

    # Warten, bis Ubuntu installiert wurde
    Write-Host "INFO: Warte auf die Installation von Ubuntu..." -Fore Yellow

    # Prüfen, ob die Ubuntu-Instanz verfügbar ist
    do {
        Start-Sleep -Seconds 1
        
        # Befehl ausführen
        $output = wsl -l | Where-Object { $_ -replace "`0","" -match '^Ubuntu' }
        
        # Prüfen, ob ein Ergebnis vorhanden ist
        if ($output) {
            Write-Host "INFO: Ubuntu gefunden. Skript wird fortgesetzt." -Fore Green
            break # Schleife verlassen, wenn Bedingung erfüllt ist
        } else {
            Write-Host "INFO: Warten auf Ubuntu-Installation..." -Fore Yellow
        }
    } while ($true)

    # Download des Installationsskripts von GitHub und Ausführung
    $scriptUrl = "https://raw.githubusercontent.com/Doppelp0int/batch/refs/heads/main/WSL_install_Docker.sh"
    $outputPath = "C:\temp\WSL_install_Docker.sh"
    Write-Host "INFO: Download des Installationsskripts von GitHub..." -Fore Yellow
    Invoke-WebRequest -Uri $scriptUrl -OutFile $outputPath
    # Führe das Skript in der WSL-Umgebung aus
    wsl -u root bash -c "cd /mnt/c/temp && bash ./WSL_install_Docker.sh"
    Write-Host "INFO: Installationsskript erfolgreich ausgeführt." -Fore Green
    # Bereinige das Skript nach der Ausführung
    try {
        Remove-Item -Path $outputPath -Force
        Write-Host "INFO: Skript erfolgreich gelöscht." -Fore Green
		Start-Sleep -Seconds 1
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
        Write-Host "CHECK: WSL funktioniert einwandfrei!" -Fore Yellow
    } catch {
        Write-Host "CHECK: Problem mit WSL erkannt. Deinstallation wird durchgeführt." -Fore Red
        Uninstall-WSL
        Install-WSL
    }

    # Installiere und konfiguriere Ubuntu
    Install-Ubuntu
	cls
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Start-Sleep -Seconds 1
    Write-Host "READY!: Ubuntu wurde erfolgreich installiert und eingerichtet." -Fore Green
	Start-Sleep -Seconds 1
    Write-Host "READY: Öffne Portainer...https://localhost:9443/#!/init/admin - Installer wird geschlossen......" -Fore Green
    Start-Process cmd -ArgumentList '/c','start https://localhost:9443/#!/init/admin' # auto close
    Start-Sleep -Seconds 7
    Exit
} catch {
    Write-Host "ERROR: Ein unerwarteter Fehler ist aufgetreten." -Fore Red
    throw $_
}

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
Write-Host "                    |          Version 2.4 -> 01.10.2024            |            " -ForegroundColor Cyan
Write-Host "                    |                                               |            " -ForegroundColor Cyan
Write-Host "                    |                                               |            " -ForegroundColor Cyan
Write-Host "                    -------------------------------------------------            " -ForegroundColor Cyan
Write-Host "`n"


# Prüfen ob WSL bereits aktiviert ist
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslFeature.State -eq "Enabled") {
    Write-Host "WSL ist bereits aktiviert."
} else {
    Write-Host "WSL ist nicht aktiviert. WSL wird nun aktiviert..." -ForegroundColor Red
    # WSL Feature aktivieren
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart 
}

# Prüfen ob die Virtual Machine Platform (für WSL2 erforderlich) bereits aktiviert ist
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform 

if ($vmFeature.State -eq "Enabled") {
    Write-Host "Die Virtual Machine Platform ist bereits aktiviert."
} else {
    Write-Host "Die Virtual Machine Platform wird aktiviert..."
    # Virtual Machine Platform aktivieren (für WSL2 erforderlich)
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform 
}

# Neustart anfordern, falls eines der Features aktiviert wurde
if (($wslFeature.State -ne "Enabled") -or ($vmFeature.State -ne "Enabled")) {
    Write-Host "Bitte starte den Computer neu und führe das Skript danach erneut aus." -ForegroundColor DarkRed -BackgroundColor Yellow
    exit
}

# WSL2 als Standardversion setzen
wsl --set-default-version 2
Write-Host "WSL2 ist nun als Standardversion gesetzt."

# Ubuntu Installation mit dem neuen Web-Installationsbefehl (kein neues Fenster öffnen)
Write-Host "Ubuntu wird nun installiert..."

# WSL Installationsprozess ohne neues Fenster
Start-Process "wsl.exe" -ArgumentList "--update" -Wait #-NoNewWindow
Start-Sleep -Seconds 3
Start-Process "wsl.exe" -ArgumentList "--install -d Ubuntu --no-launch" -Wait #-NoNewWindow
Start-Sleep -Seconds 3
Start-Process "ubuntu.exe" -ArgumentList "install --root" -Wait #-NoNewWindow
#Start-Sleep -Seconds 3
#Start-Process "wsl.exe" -ArgumentList "-d ubuntu --user root" -Wait -NoNewWindow


# Warten bis Ubuntu initialisiert ist
Start-Sleep -Seconds 3

# Bash-Skript herunterladen und in WSL ausführen
Write-Host "Bash-Skript wird heruntergeladen und ausgeführt..."
$bashScriptUrl = "https://raw.githubusercontent.com/Doppelp0int/batch/refs/heads/main/WSL_install_Docker.sh"
Start-Sleep -Seconds 3
$bashScriptPath_Windows = "C:\Users\$env:USERNAME\Downloads\WSL_install_Docker.sh"
$bashScriptPath = "/mnt/c/Users/$env:USERNAME/Downloads/WSL_install_Docker.sh"

Invoke-WebRequest -Uri $bashScriptUrl -OutFile $bashScriptPath_Windows

# Bash-Skript in WSL (Ubuntu) ausführen
#Start-Process "wsl.exe" -ArgumentList "--exec 'bash $bashScriptPath'"
wsl -e sh -c $bashScriptPath
#wsl -d Ubuntu bash $bashScriptPath
Start-Process cmd -ArgumentList '/c','start ubuntu.exe' # auto close
Start-Sleep -Seconds 3
Start-Process cmd -ArgumentList '/c','start https://localhost:9443' # auto close
Write-Host "Das Bash-Skript wurde erfolgreich ausgefuehrt." -ForegroundColor Green
Remove-Item $bashScriptPath_Windows -Force
Start-Sleep -Seconds 10
Write-Host "DONE!! PowerShell Wizard schließt in 10 Sekunden!"-ForegroundColor White -BackgroundColor Green
Exit

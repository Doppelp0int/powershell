if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
# Prüfen ob WSL bereits aktiviert ist
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslFeature.State -eq "Disabled") {
    Write-Host "WSL ist deaktiviert."
} else {
    Write-Host "WSL ist nicht deaktiviert. WSL wird nun deaktiviert..." -ForegroundColor Red
    # WSL Feature aktivieren
    wsl.exe --unregister Ubuntu
    ws.exe --uninstall
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart 
}
# Prüfen ob die Virtual Machine Platform (für WSL2 erforderlich) bereits aktiviert ist
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform 
if ($vmFeature.State -eq "Disabled") {
    Write-Host "Die Virtual Machine Platform ist bereits deaktiviert."
} else {
    Write-Host "Die Virtual Machine Platform wird deaktiviert..."
    # Virtual Machine Platform aktivieren (für WSL2 erforderlich)
    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
}
# Neustart anfordern, falls eines der Features aktiviert wurde
if (($wslFeature.State -ne "Disabled") -or ($vmFeature.State -ne "Disabled")) {
    Write-Host "Bitte starte den Computer neu und führe das Skript danach erneut aus." -ForegroundColor DarkRed -BackgroundColor Yellow
Start-Sleep -Seconds 7
    exit
}
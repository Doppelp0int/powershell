$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$Installed = $false

$uninstallKeys = Get-ChildItem -Path $registryPath

foreach ($key in $uninstallKeys) {
    $displayName = (Get-ItemProperty -Path $key.PSPath).DisplayName

    if ($displayName -match "Dell Command*") {
        $Installed = $true
        break
    }
}

if ($Installed) {
    Write-Host "Dell Command ist auf diesem System installiert."
} else {
    Write-Host "Dell Command ist nicht auf diesem System installiert. Die Installation wird gestartet..."

    $url = "https://downloads.dell.com/FOLDER10791716M/1/Dell-Command-Update-Windows-Universal-Application_JCVW3_WIN_5.1.0_A00.EXE"
    $msiName = "Dell-Command-Update-Windows-Universal-Application_1WR6C_WIN_5.0.0_A00.EXE"
    $downloadPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), $msiName)

    # Die MSI-Datei herunterladen
    try {
        Start-BitsTransfer -Source $url -Destination $downloadPath
    } catch {
        Write-Host "Fehler beim Herunterladen der Datei: $_"
        exit
    }

    # Überprüfen, ob die Datei erfolgreich heruntergeladen wurde
    if (Test-Path $downloadPath) {
        # Stille Installation der heruntergeladenen MSI-Datei
        Start-Process -Wait -FilePath $downloadPath -ArgumentList "/s"
        Remove-Item $downloadPath
        Write-Host "Die Installation von $msiName wurde abgeschlossen."
    } else {
        Write-Host "Die Datei wurde nicht erfolgreich heruntergeladen."
    }
}

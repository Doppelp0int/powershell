$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$zoomInstalled = $false

$uninstallKeys = Get-ChildItem -Path $registryPath

foreach ($key in $uninstallKeys) {
    $displayName = (Get-ItemProperty -Path $key.PSPath).DisplayName

    if ($displayName -match "Zoom") {
        $zoomInstalled = $true
        break
    }
}

if ($zoomInstalled) {
    Write-Host "Zoom ist auf diesem System installiert."
} else {
    Write-Host "Zoom ist nicht auf diesem System installiert. Die Installation wird gestartet."

    # Zoom herunterladen und installieren
    $url = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
    $msiName = "ZoomInstallerFull.msi"
	$args = ""
    $downloadPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "$msiName")

    # Die MSI-Datei herunterladen
    Start-BitsTransfer -Source $url -Destination $downloadPath

    # Stille Installation der heruntergeladenen MSI-Datei
    Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" /qn"

    Write-Host "Die Installation von $msiName wurde abgeschlossen."
}

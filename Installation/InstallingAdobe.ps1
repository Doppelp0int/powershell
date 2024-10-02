$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$zoomInstalled = $false

$uninstallKeys = Get-ChildItem -Path $registryPath

foreach ($key in $uninstallKeys) {
    $displayName = (Get-ItemProperty -Path $key.PSPath).DisplayName

    if ($displayName -match "Adobe") {
        $zoomInstalled = $true
        break
    }
}

if ($zoomInstalled) {
    Write-Host "Adobe ist auf diesem System installiert."
} else {
    Write-Host "Adobe ist nicht auf diesem System installiert. Die Installation wird gestartet."

    # Zoom herunterladen und installieren
    $url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300620320/AcroRdrDC2300620320_en_US.exe"
    $msiName = "AcroRdrDC2300620320_en_US.exe"
	$args = ""
    $downloadPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "$msiName")

    # Die MSI-Datei herunterladen
    Start-BitsTransfer -Source $url -Destination $downloadPath

    # Stille Installation der heruntergeladenen MSI-Datei
    Start-Process -Wait -FilePath $downloadPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES"

    Write-Host "Die Installation von $msiName wurde abgeschlossen."
}

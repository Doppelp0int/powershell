# Sucht nach 7-Zip-Installationen
$softwareList = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*7-Zip*" }

# Deinstalliert jede gefundene 7-Zip-Installation
foreach ($software in $softwareList) {
    $uninstallCommand = "msiexec /x $($software.IdentifyingNumber) /qn"
    Write-Host "Deinstalliere $($software.Name)..."
    Start-Process -FilePath cmd.exe -ArgumentList "/c $uninstallCommand" -Wait
    Write-Host "$($software.Name) wurde deinstalliert."
}

# Bestätige die Deinstallation
Write-Host "Deinstallation abgeschlossen."

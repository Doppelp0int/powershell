function Get-LastVersion {
    param(
        [string]$url
    )
    $webRequest = Invoke-WebRequest -Uri $url
    $content = $webRequest.Content
    return $content
}

function Send-EmailNotification {
    param(
        [string]$recipient,
        [string]$subject,
        [string]$body,
        [string]$from,
        [string]$smtpServer
    )
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $msg = New-Object Net.Mail.MailMessage
    $msg.From = $from
    $msg.To.Add($recipient)
    $msg.Subject = $subject
    $msg.Body = $body
    $msg.IsBodyHtml = $true # Setze den HTML-Modus für den E-Mail-Body
    $smtp.Send($msg)
}

# URL zum Extrahieren der Versionen
$url = "https://riverbird.de/downloads/"

# HTML-Inhalt abrufen
$htmlContent = Get-LastVersion -url $url

# Verwenden eines regulären Ausdrucks, um Name und Version zu extrahieren
$versionRegex = [regex]'<h3 class="grve-box-title grve-h3">(?<Name>[^<]+)\s(?<Version>\d+\.\d+\.\d+\.\d+)</h3>'
$matches = $versionRegex.Matches($htmlContent)

# Pfad zum Speichern der Versionen
$outputPath = "C:\Temp\Versionen.txt"

# Versionen aus der Datei lesen, wenn die Datei vorhanden ist
$existingVersions = @()
if (Test-Path $outputPath) {
    $existingVersions = Get-Content -Path $outputPath
}

# Neue Versionen sammeln und in Datei speichern
$newVersions = @()
if ($matches.Count -gt 0) {
    foreach ($match in $matches) {
        $name = $match.Groups['Name'].Value
        $version = $match.Groups['Version'].Value
        $newVersions += "$name $version"
    }
    $newVersions | Out-File -FilePath $outputPath -Encoding utf8
} else {
    Write-Output "Versionen nicht gefunden."
}

# Vergleichen der alten und neuen Versionen
$changes = Compare-Object -ReferenceObject $existingVersions -DifferenceObject $newVersions

# Wenn Änderungen festgestellt wurden, E-Mail-Benachrichtigung senden
if ($changes) {
    # Formatieren des Änderungsobjekts zu einem lesbaren Text
    $changesText = ""
    foreach ($change in $changes) {
        if ($change.SideIndicator -eq "<=") {
            $changesText += "Alte Version: $($change.InputObject)<br />"
        } elseif ($change.SideIndicator -eq "=>") {
            $changesText += "Neue Version: $($change.InputObject)<br />"
        }
    }

    $subject = "Report | Riverbird | Neue Version verfügbar!"
    $body = @"
<html>
<body>
<p><b>Dieser Report wurde ausgelöst!</b></p>
<p></p>
<p>Folgende Änderungen wurden festgestellt:</p>
<p>$changesText</p>
<p></p>
<p style="color: blue;">Dieser Bericht wird täglich um 12 Uhr automatisch gestartet, indem die Aufgabenplanung und PowerShell verwendet werden.</p>
</body>
</html>
"@

    Send-EmailNotification -recipient "******" -subject $subject -body $body -from "******" -smtpServer "*******"
} else {
    Write-Host "Keine Änderungen festgestellt."
}

# Abspeichern der aktuellen Versionen
$newVersions | Out-File -FilePath $outputPath -Encoding utf8

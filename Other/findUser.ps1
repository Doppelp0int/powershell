# Definiere die Benutzer
$users = @("USER1", "USER2")

# Finde laufende Prozesse
Write-Host "Laufende Prozesse:" -ForegroundColor Cyan
foreach ($user in $users) {
    Write-Host "Prozesse für Benutzer ${user}:" -ForegroundColor Yellow
    Get-WmiObject Win32_Process | Where-Object { $_.GetOwner().User -eq $user } | 
        Select-Object Name, ProcessId, @{Name="StartTime";Expression={$_.ConvertToDateTime($_.CreationDate)}} |
        Format-Table -AutoSize
    Write-Host "-----------------------------"
}

# Finde geplante Aufgaben
Write-Host "Geplante Aufgaben:" -ForegroundColor Cyan
foreach ($user in $users) {
    Write-Host "Geplante Aufgaben für Benutzer ${user}:" -ForegroundColor Yellow
    Get-ScheduledTask | Where-Object { $_.Principal.UserId -eq $user } | 
        Select-Object TaskName, TaskPath, State |
        Format-Table -AutoSize
    Write-Host "-----------------------------"
}

# Finde Dienste
Write-Host "Dienste:" -ForegroundColor Cyan
foreach ($user in $users) {
    Write-Host "Dienste für Benutzer ${user}:" -ForegroundColor Yellow
    Get-WmiObject Win32_Service | Where-Object { $_.StartName -eq $user } | 
        Select-Object Name, DisplayName, State, StartMode |
        Format-Table -AutoSize
    Write-Host "-----------------------------"
}

# Finde lokale Gruppenmitgliedschaften
Write-Host "Lokale Gruppenmitgliedschaften:" -ForegroundColor Cyan
foreach ($user in $users) {
    Write-Host "Gruppenmitgliedschaften für Benutzer ${user}:" -ForegroundColor Yellow
    Get-LocalGroup | ForEach-Object {
        $group = $_
        Get-LocalGroupMember -Group $group.Name | Where-Object { $_.Name -eq $user } | 
            Select-Object @{Name="GroupName";Expression={$group.Name}}, Name |
            Format-Table -AutoSize
    }
    Write-Host "-----------------------------"
}

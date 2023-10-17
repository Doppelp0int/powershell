$EmailTo = "davidstebner@web.de" 
$EmailFrom = "node@gartenkriege.de"
$Subject = "Monitoring Error" 
$Body = "Test Email"  
$SMTPServer = "shared02.keymachine.de" 
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("doppel@gartenkriege.de", "****");
$SMTPClient.Send($SMTPMessage)

$EmailTo = "SENDTO@web.de" 
$EmailFrom = "FROM@gmx.de"
$Subject = "Monitoring Error" 
$Body = "Test Email"  
$SMTPServer = "SMTPSERVER" 
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("EMAILFROM", "PASSWORDFROM");
$SMTPClient.Send($SMTPMessage)

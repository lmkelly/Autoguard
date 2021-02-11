
##############

mkdir C:\.wg | attrib +h C:\.wg
wg genkey | tee C:\.wg\pvt.tmp | wg pubkey > C:\.wg\pub.tmp

$hostname = $env:COMPUTERNAME
$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
New-Item -Path "C:\.wg\$hostname-config.txt" -ItemType "file"
$pub_key = Get-Content -Path C:\.wg\pub.tmp
Add-Content -Path "C:\.wg\$hostname-config.txt" -Value "PublicKey = $pub_key*Endpoint = $ip`:52335"

$From = "sndcapstone@gmail.com"
$To = "ostcapstone@gmail.com"
$Attachment = "C:\.wg\$hostname-config.txt"
$Subject = "$hostname Config"
$Body = "sent automatically through the power of my shitty script"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
-Credential (Get-Credential) -Attachments $Attachment

#pscp.exe -i C:\deployer_key.ppk "C:\.wg\$hostname-config.txt" deployer@104.131.19.90:/home/deployer/wg/incoming_config
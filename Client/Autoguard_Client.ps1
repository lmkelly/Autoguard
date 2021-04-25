
#Storeline: Installs wireguard if not already present, generates public/private keypair, formats config file and emails it to the osTicket/wireguard server

#Checks to see if wireguard is installed, if not installs it
if(-not (Test-Path "C:\Program Files\WireGuard\wireguard.exe")){
    (New-Object System.Net.WebClient).DownloadFile("https://download.wireguard.com/windows-client/wireguard-amd64-0.1.1.msi", ("C:\wireguard-amd64-0.1.1.msi"))
    cd C:\
    .\wireguard-amd64-0.1.1.msi
}

#Creates invisable directory and generates privaste/public keypair
mkdir C:\.wg | attrib +h C:\.wg
wg genkey | tee C:\.wg\pvt.tmp | wg pubkey > C:\.wg\pub.tmp

#Prompts user for email
$From = read-host -prompt "Enter your email"
#Gets the hostname of computer
$hostname = $env:COMPUTERNAME
#Gets client's public IP
$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
#Creates config file
New-Item -Path "C:\.wg\$hostname-config.txt" -ItemType "file"
#Grabs new public key
$pub_key = Get-Content -Path C:\.wg\pub.tmp
#Adds required content for back end to the config file
Add-Content -Path "C:\.wg\$hostname-config.txt" -Value "PublicKey = $pub_key*Endpoint = $ip`:42069*$From*$hostname*"

#Formats email to be sent
$To = "ostcapstone@gmail.com"
$Attachment = "C:\.wg\$hostname-config.txt"
$Subject = "$hostname Config"
$Body = "Capstone"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
#Sents email to osticket inbox with config file attached
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
-Credential (Get-Credential -Message "Authenticate email" -UserName $From) -Attachments $Attachment

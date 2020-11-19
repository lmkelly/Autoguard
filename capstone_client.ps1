mkdir C:\.wg | attrib +h C:\.wg
wg genkey | tee C:\.wg\pvt.tmp | wg pubkey > C:\.wg\pub.tmp

$hostname = $env:COMPUTERNAME
$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
New-Item -Path ".\$hostname-config.txt" -ItemType "file"
$pub_key = Get-Content -Path .\pub.tmp
Add-Content -Path "./$hostname-config.txt" -Value "PublicKey = $pub_key*Endpoint = $ip`:52335"

pscp.exe -i C:\Users\arest\Desktop\deployer_key.ppk "$hostname-config.txt" deployer@104.131.19.90:/home/deployer/wg/incoming_config
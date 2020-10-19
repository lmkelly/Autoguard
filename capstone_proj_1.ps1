#Storyline: Automate wireguard configuration 

#Check if chocolatey is installed
<#
$testchoco = powershell choco -v
if(-not($testchoco)){
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Continue
}
#>

#Check if wireguard is installed, if not install

if(-not (Test-Path "C:\Program Files\WireGuard\wireguard.exe")){
    (New-Object System.Net.WebClient).DownloadFile("https://download.wireguard.com/windows-client/wireguard-amd64-0.1.1.msi", ("C:\wireguard-amd64-0.1.1.msi"))
    cd C:\
    .\wireguard-amd64-0.1.1.msi
}


# Creates and opens an invisible wireguard tunnel with the server

C:\'Program Files'\WireGuard\wireguard.exe /installtunnelservice C:\WG_Server.conf

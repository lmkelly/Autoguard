$Directory = "C:\Users\arest\Downloads"

Function Get-FileName($Directory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.initialDirectory = $Directory
  $OpenFileDialog.filter = "Config (*.conf) | *.conf"
  $OpenFileDialog.ShowDialog() | Out-Null
  $Name = $OpenFileDialog.FileName
  $fileContent = Get-Content $Name
  $pvt_key = Get-Content "C:\.wg\pvt.tmp"
  $textToAdd = "`nPrivateKey = $pvt_key"
  $fileContent[0] += $textToAdd
  $fileContent | Set-Content $Name
}

Get-FileName

$hostname = $env:COMPUTERNAME

rm C:\.wg\pub.tmp
rm C:\.wg\pvt.tmp
rm "C:\.wg\$hostname-config.txt"
#C:\'Program Files'\WireGuard\wireguard.exe /installtunnelservice C:\WG_Server.conf
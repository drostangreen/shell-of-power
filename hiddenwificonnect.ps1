# Connects users to hidden wifi networks with the "connect Automatically selected"
# Change the name of the "example_wifi_vars.ps1" file to "wifi_vars.ps1" and set the options before running
# Place both files in same folder and then run

$filePath = "C:\temp"

$varsFile = Join-Path -Path $PSScriptRoot -ChildPath "wifi_vars.ps1"

. $varsFile

# Create a Wi-Fi profile
$WifiProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
  <name>$ProfileName</name>
  <SSIDConfig>
    <SSID>
      <name>$ProfileName</name>
    </SSID>
    <nonBroadcast>true</nonBroadcast>
  </SSIDConfig>
  <connectionType>ESS</connectionType>
  <connectionMode>auto</connectionMode>
  <MSM>
    <security>
      <authEncryption>
        <authentication>WPA2PSK</authentication>
        <encryption>AES</encryption>
        <useOneX>false</useOneX>
      </authEncryption>
      <sharedKey>
        <keyType>passPhrase</keyType>
        <protected>false</protected>
        <keyMaterial>$Password</keyMaterial>
      </sharedKey>
    </security>
  </MSM>
</WLANProfile>
"@
 
# Check for $filePath
if (-not (test-path $filePath)){
    New-Item -Path $filePath -ItemType Directory
}

# Export the profile to an XML file
$WifiProfile | Out-File -FilePath "$filePath\$ProfileName.xml"
 
Set-Location $filePath
 
# Add the profile to the Wi-Fi interface
netsh wlan add profile filename="$ProfileName.xml"
 
# Connect to the Wi-Fi network
netsh wlan connect name=$ProfileName

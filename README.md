# Active Directory Assessment and Privilege Escalation Script
![adape](https://raw.githubusercontent.com/hausec/ADAPE-Script/dev/Screenshots/ADAPE.PNG)

Let me first say I take absolutely no credit for the modules used in this script. A massive thanks to @TimMedin, @Kevin_Robertson, @harmj0y and @mattifestation for the modules used in this script. Finally, thanks to @DanielhBohannon for writing Invoke-Obfuscation, which was used to obfuscate all the modules in this script. I'm just the guy that paired it all together.

In my engagements and assessments, I often run a few Powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I use routinely and autoruns the functions I use in those scripts, outputting the results into a zip file. 

This script will do the following:

•	Gather hashes via WPAD, LLMNR, and NBT-NS spoofing

•	Check for GPP password (MS14-025)

•	Gather hashes for accounts via Kerberoast

•	Map out the domain and identify targets via BloodHound

•	Check for privilege escalation methods

•	Search for open SMB shares on the network 

•	Search those shares and other accessible directories for sensitive files and strings (Passwords, PII, or whatever your want, really). By default it's looking for the term "password". If you wanted to search for CVVs for example, you'd just add it next to 'password', e.g. password,cvv 

•	Check patches of systems on the network

•	Search for file servers

•	Search attached shares 

•	Gather the domain policy

This script will completely run on it's own, without using the internet at all. All the scripts needed are obfuscated powershell and included, so it should bypass most basic AV solutions. I understand the hesitation to run obfuscated powershell, so I won't be offended if you don't use this. If you're really curious, run it in a sandbox.
By default, if it detects Windows 8 and above, it will add an exclusion folder to Windows Defender and then run. You can comment it out if needed.

The functions are built into the obfuscated script and will run in memory with the exception of Inveigh, which will create a .psm1 module in the same path this script is ran in. Here's the modules used and the functions ran:
The script is ran with switch options, which are also shown below.

Inveigh - https://github.com/Kevin-Robertson/Inveigh/blob/master/Scripts/Inveigh.ps1
Functions being ran (Changeable in the script): Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5
Switch: -Inv

Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1
Function being ran: Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 
Switch: -Kerberoast

Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe
Function being ran: Invoke-BloodHound -CollectionMethod All -NoSaveCache -RandomFilenames -Threads 50 -JSONFolder $path
Switch: -Bloodhound

Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1
Function being ran: Get-GPP
Switch: -GPP

PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1
Function being ran: Invoke-AllChecks | Out-File $path\PrivEsc.txt
Switch: -PrivEsc

PowerView - https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1
Functions being ran:
	Invoke-ShareFinder -CheckShareAccess -Threads 80 | Out-File $path\ShareFinder.txt
	Get-ExploitableSystem -Verbose | Export-Csv $path\ExploitableSystem.txt
	Get-NetFileServer | Out-File $path\FileServers.txt
	net share | Out-File $path\NetShare.txt
	Get-DomainPolicy | Out-File $path\DomainPolicy.txt
Switch: -PView

Or if you want to run all of them
Switch: -All

The script will ask to run as admin, as it requires it. If you do not have admin access, it will only run the privilege escalation and Bloodhound functions. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). 

After running the .ps1, it will create the capture file in the same folder it's being ran in and zips it. If you're running Windows 7 and below it won't zip, so you'll have to do that yourself. At the end of the script, it deletes all the folders it created (except the .zip file, obviously). 

GPP password checking and searching sensitive files takes awhile, so don't be surprised if this script takes a long time to finish depending on the number of domain controllers, open shares, and strings you're searching for. Comment those sections out if they take too long to run. 

Usage:
Set-ExecutionPolicy Bypass 
./ADAPE.ps1 -All
or 
./ADAPE.ps1 -GPP -PView -Kerberoast
etc.
# Active Directory Assessment and Privilege Escalation Script
![ScreenShot](https://raw.githubusercontent.com/hausec/ADAPE-Script/dev/Screenshots/ADAPE.PNG)
Let me first say I take absolutely no credit for the modules used in this script. A massive thanks to Tim Medin, Kevin Robertson, Marcello Salvati, Will Schroeder and the rest of the team at Specter Ops for the modules used in this script. Finally, thanks to Daniel Bohannon for writing Invoke-Obfuscation, which was used to obfuscate all the modules in this script. I'm just the guy that paired it all together.

In my engagements and assessments, I often run a few powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I use routinely and autoruns the functions I use in those scripts, outputting the results into a zip file. 

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

This script will completely run on it's own, without using the internet at all. All the scripts needed are obfuscated powershell and included, so it should bypass AV completely. 
![ScreenShot](https://raw.github.com/hausec/ADAPE-Script/dev/Screenshots/VirusTotal.png)

It uses the following modules:

Inveigh - https://github.com/Kevin-Robertson/Inveigh/blob/master/Scripts/Inveigh.ps1

Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1

Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe

Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1

PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1

PowerView - https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1

The script will ask to run as admin, as it requires it. If you do not have admin access, it will only run the privilege escalation module. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). 

After running the .ps1, it will create the capture file in the same folder it's being ran in and zips it. At the end of the script, it deletes all the folders it created (except the .zip file, obviously). 

GPP password checking and searching sensitive files takes awhile, so don't be surprised if this script takes a long time to finish depending on the number of domain controllers, open shares, and strings you're searching for. Comment those sections out if they take too long to run. 

Usage:
PowerShell.exe -ExecutionPolicy Bypass ./ADAPE.ps1
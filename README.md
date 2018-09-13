# Active Directory Assessment and Privilege Escalation Script
In my engagements and assessments, I often run a few powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I use routinely and autoruns the functions I use in those scripts, outputting the results into a zip file. 

This script will do the following:

•	Gather hashes via WPAD, LLMNR, and NBT-NS spoofing

•	Check for GPP password (MS14-025)

•	Gather hashes for accounts via Kerberoast

•	Map out the domain and identify targets via BloodHound

•	Check for privilege escalation methods

•	Search for open SMB shares on the network 

•	Search those shares and other accessible directories for sensitive files and strings (Passwords, PII, or whatever your want, really). By default it's looking for the terms "password,ssn". If you wanted to search for CVVs for example, you'd just add it next to 'ssn', e.g. password,ssn,cvv 

•	Check patches of systems on the network

•	Search for file servers

•	Search attached shares 

•	Gather the domain policy

The script will attempt to download the required modules from Github, then erase them after it's done. However, some sites don't allow connections to Github or downloads, so it has local functionality too. To use it, just download the required modules below and store them in the same folder as this script and it will work without needing the internet. I recommend doing this anyways to bypass AV. 

Inveigh - https://github.com/Kevin-Robertson/Inveigh/blob/master/Scripts/Inveigh.ps1

Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1

Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe

Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1

PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1

PowerView - https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1

The script will ask to run as admin, as it requires it. If you do not have admin access, it will only run the privilege escalation module. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). 

After running the .ps1, it will create the capture file and start creating module folders to store the downloaded scripts into. Everything captured is stored and zipped up into the C:/Capture.zip file. This can be changed, i.e. if C:/ cannot be be written to, change the directory in the code under the comment that says "Change storage directory here". If AV catches the modules (Bloodhound and Powerview usually get picked up right away), I suggest locally running those after editing those modules to avoid AV. Here's an article I wrote on how to evade AV https://hausec.com/2018/08/23/av-evasion/

At the end of the script, it deletes all the folders it created (except the .zip file, obviously). 

GPP password checking and searching sensitive files takes awhile, so don't be surprised if this script takes a long time to finish depending on the number of domain controllers, open shares, and strings you're searching for. Comment those sections out if they take too long to run. 

Usage: Just run the script

PowerShell.exe -ExecutionPolicy Bypass ./ADAPE.ps1


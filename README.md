# Active Directory Assessment and Privilege Escalation Script
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

There's two parameter options to use this script: 'local' or 'external'

When using the local parameter, it will look for the required modules in the same folder it's being ran in, then run them. This option is recommended, as Inveigh and Powerview get caught by AV pretty quick, so I suggest "obfuscating" them so AV doesn't catch them. I wrote an article on how to do that here

https://hausec.com/2018/08/23/av-evasion/

When using the external parameter, it will fetch the required modules from Github automatically and run them. Again, Powerview and Inveigh get caught by virtually all AV, so be careful. 

It uses the following modules:

Inveigh - https://github.com/Kevin-Robertson/Inveigh/blob/master/Scripts/Inveigh.ps1

Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1

Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe

Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1

PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1

PowerView - https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1

The script will ask to run as admin, as it requires it. If you do not have admin access, it will only run the privilege escalation module. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). 

After running the .ps1, it will create the capture file in the same folder it's being ran in and start creating module folders to store the downloaded scripts into. 
At the end of the script, it deletes all the folders it created (except the .zip file, obviously). 

GPP password checking and searching sensitive files takes awhile, so don't be surprised if this script takes a long time to finish depending on the number of domain controllers, open shares, and strings you're searching for. Comment those sections out if they take too long to run. 

Usage:
PowerShell.exe -ExecutionPolicy Bypass ./ADAPE.ps1 local

or 

PowerShell.exe -ExecutionPolicy Bypass ./ADAPE.ps1 external
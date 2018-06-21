# Active Directory Assessment and Privilege Escalation Script
In my engagements and assessments, I often run a few powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I use routinely and autoruns the functions I use in those scripts, outputting the results into a zip file. 

This script will do the following:

•	Check for GPP password (MS14-025)

•	Gather hashes for accounts via Kerberoast

•	Map out the domain and identify targets via BloodHound

•	Check for privilege escalation methods

•	Search for open SMB shares on the network 

•	Search those shares and other accessible directories for sensitive files and strings (Passwords, PII, or whatever your want, really). By default it's looking for the terms "password,ssn". If you wanted to search for CVVs for example, you'd just add it next to 'ssn', e.g. password,ssn,cvv 

•	Check patches of systems on the network

There's two .ps1 scripts here: LADAPE and ADAPE. LADAPE is the local version, meaning it will not reach out to the internet and fetch the modules, they must be present in the same folder as the LADAPE script. I made this because some sites don't allow connections to github, don't like the cert github has, or don't even have internet, thus the need for a full local script.

The modules LADAPE uses are linked here and named the same way, so just download the following modules and put them in the same folder as LADAPE.ps1 and it should execute.

Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1

Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe

Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1

PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1

PowerView - https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1

The script will ask to run as admin, as it requires it. If you do not have admin access, it will only run the privilege escalation module. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). 

After running the .ps1, it will create the capture file and start creating module folders to store the downloaded scripts into. Everything captured is stored and zipped up into the C:/Capture.zip file. This can be changed, i.e. if C:/ cannot be be written to, change the directory in the code under the comment that says "Change storage directory here". Bloodhound's "Sharphound.ps1" has recently been updated to Windows Defender to be flagged as malicious, but ironically the Sharphound.exe has not. I've switched the script to use the .exe by default, as the new 1.5 version of Sharphound is still not being picked up by any AV engine (according to Virus Total). If you don't want to use the .exe, you can comment that section out and use the .ps1 still. I've obfuscated the .ps1 section a bit by downloaded the .ps1 as a string, base64 encoding it, then decoding it and storing it as a new .ps1 to change the signature (now only Windows Defender catches it, hence the .exe usage). 
At the end of the script, it deletes all the folders it created (except the .zip file, obviously). 

GPP password checking and searching sensitive files takes awhile, so don't be surprised if this script takes 30 minutes to finish depending on the number of domain controllers and strings you're searching for. Comment those sections out if they take too long to run. 

Usage: Just run the script

PowerShell.exe -ExecutionPolicy Bypass ./ADAPE.ps1


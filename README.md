# AD Asessment and Privilege Escalation Script
In my engagements and assessments, I often run a few tools once there's a foothold. This script combines the following scripts into one:

Kerberoast (https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1)

BloodHound (https://github.com/BloodHoundAD/BloodHound)

PowerUp (https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1)

There's two scripts here: One for a privileged user and one for a non-privileged user. The difference is that the non-privileged user will download modules in their Documents/WindowsPowerShell/Modules directory and store them in their Documents/Capture.zip folder, where a privileged user will use the Program Files/WindowsPowerShell/Modules and C:\Capture.
The script will download each PS script, run it, output the results to a folder and zip the folder up, then delete the modules. Feel free to change any directories and modify this is any way you like. 

More scripts and functionality will probably be added at a later date. 


Usage: Just run the script

.\ADAPELow.ps1 
or
.\ADAPEPriv.ps1 
or right click > Run with PowerShell
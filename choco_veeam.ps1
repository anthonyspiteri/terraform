Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco Install GoogleChrome -y
choco install cygwin -y
choco install cyg-get -y
cyg-get ansible

## Install  OpenSSH.Server 
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
## Install  OpenSSH.Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
## Change server start-up to Automatic 
Set-Service -Name sshd -StartupType ‘Automatic’ 
## Start the Server and change start-up to Automatic
Start-Service sshd

choco feature enable -n=exitOnRebootDetected
choco feature enable -n=useRememberedArgumentsForUpgrades

#choco install sql-server-express -y

#choco install veeam-backup-and-replication-server --params "/sqlServer:(local)\SQLEXPRESS /username:administrator /password:Veeam1!" --source='"c:\Packages;chocolatey"' -y

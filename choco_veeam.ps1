Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=exitOnRebootDetected
choco feature enable -n=useRememberedArgumentsForUpgrades

choco install sql-server-express -y

choco install veeam-backup-and-replication-server --params "/sqlServer:(local)\SQLEXPRESS /licenseFile:c:\packages\license-preview-1000-15FEB2020.lic /username:autodeploy /password:Veeam1!" --source='"c:\Packages;chocolatey"'

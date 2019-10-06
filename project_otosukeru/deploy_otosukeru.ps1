<#
.SYNOPSIS
----------------------------------------------------------------------
Project Otosukeru - Dynamic Proxy Deployment with Terraform
----------------------------------------------------------------------
Version : 0.9.5.3
Requires: Veeam Backup & Replication v9.5 Update 4 or later
Author  : Anthony Spiteri
Blog    : https://anthonyspiteri.net
GitHub  : https://www.github.com/anthonyspiteri

.DESCRIPTION
Known Issues and Limitations:
- vSphere API timeouts can happen during apply/destroy phase of Terraform. See Log file to troubleshoot.
- Speed of Proxy deployment depends on underlying infrastructure as well as VM Template. (Testing has shown 5 Windows Proxies can be deployed in 5 minutes)
#>

[CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$Windows,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$Ubuntu,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$CentOS,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$Destroy,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$Static,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$DHCP,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$SetProxies
    )

if (!$Windows -and !$Ubuntu -and !$CentOS -and !$Destroy)
    {
        Write-Host ""
        Write-Host ":: - ERROR! Script was run without using a parameter..." -ForegroundColor Red -BackgroundColor Black
        Write-Host ":: - Please use: -Windows, -Ubunut, -Centos or -Destroy" -ForegroundColor Yellow -BackgroundColor Black 
        Write-Host ""
        break
    }

$StartTime = Get-Date

#To be run on Server Isntalled with Veeam Backup & Replicaton
if (!(get-pssnapin -name VeeamPSSnapIn -erroraction silentlycontinue)) 
        {
         add-pssnapin VeeamPSSnapIn
        }

#Get Variables from Master Config
$config = Get-Content config.json | ConvertFrom-Json

function Pause
    {
        write-Host ""
        write-Host ":: Press Enter to continue..." -ForegroundColor Yellow -BackgroundColor Black
        Read-Host | Out-Null 
    }

function ConnectVBRServer
    {
        #Connect to the Backup & Replication Server and exit on fail
        Disconnect-VBRServer

        Try 
            {
                Connect-VBRServer -user $config.VBRDetails.Username -password $config.VBRDetails.Password
            }
        Catch 
            {
                Write-Host -ForegroundColor Red "ERROR: $_" -ErrorAction Stop
                Disconnect-VBRServer
                Stop-Transcript
                Write-Error -Exception  "Exiting as we couldn't connect to Veeam Server" -ErrorAction Stop
            }
    }

function WorkOutProxyCount
    {
        $JobObject = Get-VBRJob
            
        try
            {
                $Objects = $JobObject.GetObjectsInJob()
            }
        catch 
            {
                Write-Host -ForegroundColor Red "ERROR: $_" -ErrorAction Stop
                Stop-Transcript
                Write-Error -Exception "Exiting as you don't have any Jobs on the Veeam Server" -ErrorAction Stop
            }

        $JobObject = Get-VBRJob
        $VMcount = $Objects.count

        if ($VMcount -lt 10)
            {
                $VBRProxyCount = 2  
            }
        elseif ($VMcount -le 20)
            {
                $VBRProxyCount = 4
            }
        else 
            {
                $VBRProxyCount = 6
            }
    
        if($SetProxies)
            {
                $VBRProxyCount = $( Read-Host "Enter Number of Proxies to Deploy")
            }
    
        $global:ProxyCount = $VBRProxyCount
    }

function WindowsProxyBuild 
    {
        $host.ui.RawUI.WindowTitle = "Deploying Windows Proxies with Terraform"
        
        $wkdir = Get-Location
        Set-Location -Path .\proxy_windows
        & .\terraform.exe init
        & .\terraform.exe apply --var "vsphere_proxy_number=$ProxyCount" -auto-approve
        & .\terraform.exe output -json proxy_ip_addresses > ..\proxy_ips.json
        Set-Location $wkdir
    }

function LinuxProxyBuild
    {
        $host.ui.RawUI.WindowTitle = "Deploying Linux Proxies with Terraform"

        if($Ubuntu)
            {
                $distro = "ubuntu"
            }

        if($CentOS)
            {
                $distro = "centos"
            }

        $wkdir = Get-Location
        Set-Location -Path .\proxy_linux
        & .\terraform.exe init
        & .\terraform.exe apply --var "vpshere_linux_distro=$distro" --var "vsphere_proxy_number=$ProxyCount" -auto-approve
        & .\terraform.exe output -json proxy_ip_addresses > ..\proxy_ips.json
        Set-Location $wkdir
    }

function ProxyDestroy 
    {
        if($Destroy -and $Windows)
            {
                $host.ui.RawUI.WindowTitle = "Destroying Windows Proxies with Terraform"
            
                $wkdir = Get-Location
                Set-Location -Path .\proxy_windows
                & .\terraform.exe destroy --force
                Set-Location $wkdir
            }

        if($Destroy -and ($Ubuntu -or $CentOS))
            {
                $host.ui.RawUI.WindowTitle = "Destroying Linux Proxies with Terraform"

                $wkdir = Get-Location
                Set-Location -Path .\proxy_linux
                & .\terraform.exe destroy --force
                Set-Location $wkdir
            }
    }

function AddVeeamProxy
    {
        $host.ui.RawUI.WindowTitle = "Adding Veeam Proxies"
        
        $ProxyList = Get-Content proxy_ips.json | ConvertFrom-Json
        $ProxyArray =@($ProxyList)

        if(!$ProxyArray)
            {
                Write-Error -Exception "Exiting due to Terraform Proxy Deployment Issue" -ErrorAction Stop
            }

        if ($Windows) 
            {
                Add-VBRCredentials -Type Windows -User $config.VBRDetails.Username -Password $config.VBRDetails.Password -Description "Windows Domain Admin" | Out-Null
            }

        if ($Ubuntu)
            {
                Add-VBRCredentials -Type Linux -User $config.LinuxProxy.LocalUsername -Password $config.LinuxProxy.LocalPasswordUbuntu -ElevateToRoot -Description "Proxy Linux Admin"  | Out-Null
            }

        if ($CentOS)
            {
                Add-VBRCredentials -Type Linux -User $config.LinuxProxy.LocalUsername -Password $config.LinuxProxy.LocalPasswordCentOS -ElevateToRoot -Description "Proxy Linux Admin"  | Out-Null
            }

        for ($i=0; $i -lt $ProxyCount; $i++)
            {
                $ProxyEntity = $ProxyArray.value[$i]

                #Add Proxy to Backup & Replication
                Write-Host ":: Adding Proxy Server to Backup & Replication" -ForegroundColor Green 

                if ($Windows)
                    {
                        #Get and Set Windows Credential
                        $WindowsCredential = Get-VBRCredentials | where {$_.Name -eq $config.VBRDetails.Username} 

                        #Add Windows Server to VBR and Configure Proxy
                        try 
                            {
                                Add-VBRWinServer -Name $ProxyEntity -Description "Dynamic Veeam Proxy" -Credentials $WindowsCredential -ErrorAction Stop | Out-Null
                            }
                        Catch 
                            {
                                Write-Host -ForegroundColor Red "ERROR: $_" -ErrorAction Stop
		                        Get-VBRCredentials | where {$_.Name -eq $config.VBRDetails.Username} | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
                                Stop-Transcript
                                Write-Error -Exception "Exiting due to issues adding Windows Proxy to Veeam Server" -ErrorAction Stop
                            }

                        Write-Host ":: Creating New Veeam Windows Proxy" -ForegroundColor Green
                        Add-VBRViProxy -Server $ProxyEntity -MaxTasks 2 -TransportMode HotAdd -ConnectedDatastoreMode Auto -EnableFailoverToNBD | Out-Null
                    }

                if ($Ubuntu -or $CentOS)
                    {
                        #Get and Set Linux Credentials
                        $LinuxCredential = Get-VBRCredentials | where {$_.Description -eq "Proxy Linux Admin"}
                        
                        try 
                            {
                                Add-VBRLinux -Name $ProxyEntity -Description "Dynamic Veeam Proxy" -Credentials $LinuxCredential -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
                            }
                        catch 
                            {
                                Write-Host -ForegroundColor Red "ERROR: $_" -ErrorAction Stop
		                        Get-VBRCredentials | where {$_.Description -eq "Proxy Linux Admin"} | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
                                Stop-Transcript
                                Write-Error -Exception "Exiting due to issues adding Linux Proxy to Veeam Server" -ErrorAction Stop
                            }

                        Write-Host ":: Creating New Veeam Linux Proxy" -ForegroundColor Green
                        #Add-VBRViProxy -Server $ProxyEntity -MaxTasks 2 -TransportMode HotAdd -ConnectedDatastoreMode Auto -EnableFailoverToNBD
                    }

                Write-Host "--" $ProxyEntity "Configured" -ForegroundColor Yellow -BackgroundColor Black
                Write-Host
            }
    }

function RemoveVeeamProxy
    {
        $host.ui.RawUI.WindowTitle = "Removing Veeam Proxies"
        
        $ProxyList = Get-Content proxy_ips.json | ConvertFrom-Json
        $ProxyArray =@($ProxyList)
        
        for ($i=0; $i -lt $ProxyCount; $i++)
            {
                $ProxyEntity = $ProxyArray.value[$i]

                #Remove Proxy From Backup & Replication
                Write-Host ":: Removing Proxy Server from Backup & Replication" -ForegroundColor Green

                Get-VBRViProxy -Name $ProxyEntity | Remove-VBRViProxy -Confirm:$false -WarningAction SilentlyContinue | Out-Null

                Get-VBRServer -Type Windows -Name $ProxyEntity | Remove-VBRServer -Confirm:$false -WarningAction SilentlyContinue | Out-Null
                Get-VBRServer -Type Linux -Name $ProxyEntity | Remove-VBRServer -Confirm:$false -WarningAction SilentlyContinue | Out-Null

                Write-Host "--" $ProxyEntity "Removed" -ForegroundColor Red -BackgroundColor Black
                Write-Host
            }

            Get-VBRCredentials | where {$_.Name -eq $config.VBRDetails.Username} | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
            Get-VBRCredentials | where {$_.Description -eq "Proxy Linux Admin"} | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
    }

#Execute Functions

if ($Windows -and !$Destroy){
    #Run the code for Windows Proxies
    Start-Transcript logs\ProjectOtosukeru-Log.txt -Force

    $StartTimeVB = Get-Date
    ConnectVBRServer
    Write-Host ""
    Write-Host ":: - Connected to Backup & Replication Server - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVB = Get-Date
    $durationVB = [math]::Round((New-TimeSpan -Start $StartTimeVB -End $EndTimeVB).TotalMinutes,2)
    Write-Host "Execution Time" $durationVB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeLR = Get-Date
    WorkOutProxyCount
    Write-Host ""
    Write-Host ":: - Getting Job Details and Working out Dynamix Proxy Count - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeLR = Get-Date
    $durationLR = [math]::Round((New-TimeSpan -Start $StartTimeLR -End $EndTimeLR).TotalMinutes,2)
    Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeTF = Get-Date
    WindowsProxyBuild
    Write-Host ""
    Write-Host ":: - Windows Proxies Deployed via Terraform - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeTF = Get-Date
    $durationTF = [math]::Round((New-TimeSpan -Start $StartTimeTF -End $EndTimeTF).TotalMinutes,2)
    Write-Host "Execution Time" $durationTF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeTF = Get-Date
    AddVeeamProxy
    Write-Host ""
    Write-Host ":: - Windows Proxies Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeTF = Get-Date
    $durationTF = [math]::Round((New-TimeSpan -Start $StartTimeTF -End $EndTimeTF).TotalMinutes,2)
    Write-Host "Execution Time" $durationTF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if (($Ubuntu -or $CentOS) -and !$Destroy){
    #Run the code for Linux Proxies
    Start-Transcript logs\ProjectOtosukeru-Log.txt -Force

    $StartTimeVB = Get-Date
    ConnectVBRServer
    Write-Host ""
    Write-Host ":: - Connected to Backup & Replication Server - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVB = Get-Date
    $durationVB = [math]::Round((New-TimeSpan -Start $StartTimeVB -End $EndTimeVB).TotalMinutes,2)
    Write-Host "Execution Time" $durationVB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeLR = Get-Date
    WorkOutProxyCount
    Write-Host ""
    Write-Host ":: - Getting Job Details and Working out Dynamix Proxy Count - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeLR = Get-Date
    $durationLR = [math]::Round((New-TimeSpan -Start $StartTimeLR -End $EndTimeLR).TotalMinutes,2)
    Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeTF = Get-Date
    LinuxProxyBuild
    Write-Host ""
    Write-Host ":: - Windows Proxies Deployed via Terraform - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeTF = Get-Date
    $durationTF = [math]::Round((New-TimeSpan -Start $StartTimeTF -End $EndTimeTF).TotalMinutes,2)
    Write-Host "Execution Time" $durationTF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeTF = Get-Date
    AddVeeamProxy
    Write-Host ""
    Write-Host ":: - Windows Proxies Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeTF = Get-Date
    $durationTF = [math]::Round((New-TimeSpan -Start $StartTimeTF -End $EndTimeTF).TotalMinutes,2)
    Write-Host "Execution Time" $durationTF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if ($Destroy){
    #Run the code to Remove Proxies
    Start-Transcript logs\ProjectOtosukeru-Log.txt -Append
    
    $StartTimeVB = Get-Date
    ConnectVBRServer
    Write-Host ""
    Write-Host ":: - Connected to Backup & Replication Server - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVB = Get-Date
    $durationVB = [math]::Round((New-TimeSpan -Start $StartTimeVB -End $EndTimeVB).TotalMinutes,2)
    Write-Host "Execution Time" $durationVB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeCL = Get-Date
    WorkOutProxyCount
    RemoveVeeamProxy
    Write-Host ""
    Write-Host ":: - Clearing Backup & Replication Server Configuration - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeCL = Get-Date
    $durationCL = [math]::Round((New-TimeSpan -Start $StartTimeCL -End $EndTimeCL).TotalMinutes,2)
    Write-Host "Execution Time" $durationCL -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeCL = Get-Date
    ProxyDestroy
    Write-Host ""
    Write-Host ":: - Destroying Proxies with Terraform - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeCL = Get-Date
    $durationCL = [math]::Round((New-TimeSpan -Start $StartTimeCL -End $EndTimeCL).TotalMinutes,2)
    Write-Host "Execution Time" $durationCL -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

Stop-Transcript

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

$host.ui.RawUI.WindowTitle = "AUTOMATION AND ORCHESTRATION COMPLETE"
Write-Host "Total Execution Time" $duration -ForegroundColor Green -BackgroundColor Black
Write-Host
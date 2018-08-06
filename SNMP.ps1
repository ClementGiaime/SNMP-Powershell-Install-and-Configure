#Note: Server 2012 R2 servers and 2016 servers

####################################
# Description: Powershell script to install and configure SNMP Services
# Last update: 2018/08/06
####################################

### Variables ###
# ADD YOUR MANAGER(s) in format @("manager1","manager2")
$pmanagers = @("manager1") 
# ADD YOUR COMM STRING(s) in format @("Community1","Community2")
$CommString = @("Community1")

#Import ServerManger Module
Import-Module ServerManager

#Check if SNMP-Service is already installed
$check = Get-WindowsFeature -Name SNMP-Service

if ($check.Installed -ne "True") {
		#Install/Enable SNMP-Service
		Write-Host "SNMP Service Installing..."
		Add-WindowsFeature -IncludeManagementTools SNMP-Service | Out-Null
}

$check = Get-WindowsFeature -Name SNMP-Service

##Verify Windows Services Are Enabled
if ($check.Installed -eq "True"){
		Write-Host "Configuring SNMP Services..."
		#Set SNMP Permitted Manager(s) ** WARNING : This will over write current settings **
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null

		foreach ($String in $CommString){
				# Set the SNMP Community String(s) - *Read Only*
				reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $String /t REG_DWORD /d 4 /f | Out-Null
		}
		
		$i = 2
		foreach ($manager in $pmanagers){
				# Set the SNMP HOST
				reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
				$i++
		}
}
else {
		Write-Host "Error: SNMP Services Not Installed"
}
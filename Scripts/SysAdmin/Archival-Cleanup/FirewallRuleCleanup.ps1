#Fix Windows Start Menu Not Showing Up due to excess of Windows Firewall Rules

#Add feature to registry
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\" -Name "DeleteUserAppContainersOnLogoff" -Value 1 -PropertyType "DWord"

#Clean up firewall rules already established
#Cleanup Inbound Rules:
$FWInboundRules       = Get-NetFirewallRule -Direction Inbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWInboundRulesUnique = Get-NetFirewallRule -Direction Inbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 
Write-Host "# inbound rules         : " $FWInboundRules.Count
Write-Host "# inbound rules (Unique): " $FWInboundRulesUnique.Count 
if ($FWInboundRules.Count -ne $FWInboundRulesUnique.Count) {
    Write-Host "# rules to remove       : " (Compare-Object -referenceObject $FWInboundRules  -differenceObject $FWInboundRulesUnique).Count
    Compare-Object -referenceObject $FWInboundRules  -differenceObject $FWInboundRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule }

#Cleanup Outbound Rules 
$FWOutboundRules       = Get-NetFirewallRule -Direction Outbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWOutboundRulesUnique = Get-NetFirewallRule -Direction Outbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 
Write-Host "# outbound rules         : : " $FWOutboundRules.Count
Write-Host "# outbound rules (Unique): " $FWOutboundRulesUnique.Count 
if ($FWOutboundRules.Count -ne $FWOutboundRulesUnique.Count)  {
    Write-Host "# rules to remove       : " (Compare-Object -referenceObject $FWOutboundRules  -differenceObject $FWOutboundRulesUnique).Count
    Compare-Object -referenceObject $FWOutboundRules  -differenceObject $FWOutboundRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule}

#Cleanup Configurable Service Rules 
$FWConfigurableRules       = Get-NetFirewallRule -policystore configurableservicestore |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWConfigurableRulesUnique = Get-NetFirewallRule -policystore configurableservicestore |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 
Write-Host "# service configurable rules         : " $FWConfigurableRules.Count
Write-Host "# service configurable rules (Unique): " $FWConfigurableRulesUnique.Count 
if ($FWConfigurableRules.Count -ne $FWOutboundRulesUnique.Count)  {
    Write-Host "# rules to remove                    : " (Compare-Object -referenceObject $FWConfigurableRules  -differenceObject $FWConfigurableRulesUnique).Count
    Compare-Object -referenceObject $FWConfigurableRules  -differenceObject $FWConfigurableRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule}

#Sources:
#https://social.technet.microsoft.com/Forums/en-US/992e86c8-2bee-4951-9461-e3d7710288e9/windows-servr-2016-rdsh-firewall-rules-created-at-every-login?forum=winserverTS
#https://social.technet.microsoft.com/Forums/en-US/43c6344b-5a6d-4d3e-ab22-20457235aa80/start-menu-stops-working-in-terminals?forum=ws2016
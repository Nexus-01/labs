###
#
## installs the DHCP role, configures initial DHCP scopes and reservations
#
###

# install the DHCP role
Install-WindowsFeature DHCP -IncludeManagementTools

# add server as authorized DHCP server
Add-DhcpServerInDC -dnsName DC01.lab.contoso.com -IPAddress 192.168.3.11

# checks if server is in authorized DHCP server list
if ("192.168.3.11" -in $(Get-DhcpServerInDC | Select-Object -ExpandProperty IPAddress | Select-Object -ExpandProperty IPAddressToString)) {
	Write-Host "Server confirmed added to list of authorized DHCP servers" -ForegroundColor Green
} else {
	Write-Host "Something went wrong adding server to list of authorized DHCP server" -ForegroundColor Red

# configures initial DHCP scope
$InitDHCPScopeV4 = @{
	name = "primary-scope"
	StartRange = "192.168.3.0"
	EndRange = "192.168.3.255"
	SubnetMask = "255.255.255.0"
	State = "Active"
}
Add-DHCPServerV4Scope @InitDHCPScopeV4

# checks if the new scope was created
if ($InitDHCPScopeV4.name -in $(Get-DHCPServerV4Scope | Select-Object -ExpandProperty Name)) {
	Write-Host "Initial scope confirmed created" -ForegroundColor green
} else {
	Write-Host "Initial scope failed to be created" -ForegroundColor red
}

# sets additional DHCP options
@additionalOptions = @{
	ComputerName = "DC01.lab.contoso.com"
	ScopeID = "192.168.3.0"
	DNSServer = "192.168.3.11"
	Router = "192.168.3.11"
}
Set-DHCPServerV4OptionValue @additionalOptions

# sets reserverations and checks if created
$InitReservationParams = @{
	ScopeID = "192.168.3.0"
	IPAddress = "192.168.3.11"
	ClientID  = "08-00-27-6B-37-C5"
	Description = "Reservation for DC01"
}
try { Add-DhcpServerV4Reservation @InitReservationParams; Write-Host "Reservation created" -ForegroundColor green }
catch { Write-Host "Reservation was not created. Check output for more details" -ForegroundColor red }

# sets exclusion ranges
try {
	Add-DHCPServerV4ExclusionRange -ComputerName "DC01.lab.contoso.com" -ScopeID 192.168.3.0 -StartRange 192.168.3.1 -EndRange 192.168.3.10;
	Write-Host "Exclusion range created" -ForegroundColor green
}
catch {
	Write-Host "Exclusion range could not be created. Check output for more details" -ForegroundColor red
}

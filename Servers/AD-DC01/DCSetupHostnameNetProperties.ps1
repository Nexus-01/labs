###
#
## configures network settings, renames the host, restarts the device.
#
###

## configure network settings
# adapter properties
$adapterProperties = @{
	InterfaceAlias = "Ethernet"
	IPAddress = "192.168.3.11"
	AddressFamily = "IPv4"
	PrefixLength = 24
	DefaultGateway = "192.168.3.254"
}
New-NetIPAddress @adapterProperties
# set DNS server
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.168.3.11


## rename the host if not done already
if ($(Get-ComputerInfo | Select-Object -ExpandProperty CsDNSHostName) -ne "DC01") {
	Rename-Computer "DC01"
} else {
	Write-Host "Host already named to 'DC01'. Continuing..." -ForegroundColor Green
}

## restart for hostname change to take effect
Restart-Computer

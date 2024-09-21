###
#
## install the ADDS role, promote server to DC of new forest
#
###

# install the ADDS role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Verbose

# Create new ADDS Forest (this causes the server to be promoted into a DC as well)
Install-ADDSForest -DomainName "lab.contoso.com"  -InstallDNS

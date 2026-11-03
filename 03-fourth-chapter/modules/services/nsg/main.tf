resource "azurerm_network_security_group" "cluster_nsg" {
	name			= "${var.resource_prefix}-vmss-nsg"
	resource_group_name	= var.cluster_rg_name
	location		= var.resource_region
}

resource "azurerm_network_security_rule" "nsg-allow-http" {
	name		= "Allow-HTTP"
	priority	= 100
	direction	= "Inbound"
	access		= "Allow"
	protocol	= "Tcp"
	source_port_range	= "*"
	destination_port_range	= 80
	source_address_prefix	= "Internet"
	destination_address_prefix	= "*"

	resource_group_name = azurerm_network_security_group.cluster_nsg.resource_group_name
	network_security_group_name = azurerm_network_security_group.cluster_nsg.name
}

resource "azurerm_network_security_rule" "nsg-allow-lb-probe" {
	name		= "Allow-LB-Probe"
	priority	= 110
	direction	= "Inbound"
	access		= "Allow"
	protocol	= "*"
	source_port_range	= "*"
	destination_port_range	= "80"
	source_address_prefix	= "AzureLoadBalancer"
	destination_address_prefix = "*"

	resource_group_name = azurerm_network_security_group.cluster_nsg.resource_group_name
	network_security_group_name = azurerm_network_security_group.cluster_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "cluster_nsg_assoc" {
	subnet_id			= var.cluster_private_subnet_id
	network_security_group_id 	= azurerm_network_security_group.cluster_nsg.id
}

resource "azurerm_resource_group" "cluster_rg" {
	name		= "rg-${var.resource_prefix}-${var.resource_region}"
	location	= var.resource_region
}

resource "azurerm_virtual_network" "cluster_vnet" {
	name			= "${var.resource_prefix}-vnet-${var.resource_region}"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	location		= var.resource_region
	address_space		= [var.vnet_address_space[0]]
}

resource "azurerm_subnet" "cluster_private_subnet" {
	name			= "${var.resource_prefix}-sb"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	virtual_network_name	= azurerm_virtual_network.cluster_vnet.name
	address_prefixes	= ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "cluster_lb_pip" {
	name			= "${var.resource_prefix}-lb-pip"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	location		= var.resource_region
	sku			= "Standard"
	allocation_method	= "Static"
}

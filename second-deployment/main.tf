resource "azurerm_resource_group" "linux_as_rg" {
	name		= "${var.resource_group_name_prefix}-${var.availability_set_name_prefix}-${var.resource_group_location}"
	location	= "${var.resource_group_location}"
}

resource "azurerm_virtual_network" "linux_as_vnet" {
	name			= "${var.availability_set_name_prefix}-vnet-${var.resource_group_location}"
	resource_group_name	= azurerm_resource_group.linux_as_rg.name
	location		= var.resource_group_location
	address_space		= [var.vnet_available_address_spaces[2]]
}

resource "azurerm_subnet" "linux_vm_subnet" {
	name			= "${var.availability_set_name_prefix}-sb"
	resource_group_name	= azurerm_resource_group.linux_as_rg.name
	virtual_network_name	= azurerm_virtual_network.linux_as_vnet.name
	address_prefixes	= [var.first_cidr_block_mapping.first_subnet_block]
}

resource "azurerm_public_ip" "linux_as_fe_pip" {
	name			= "${var.availability_set_name_prefix}-fe-pip"
	resource_group_name	= azurerm_resource_group.linux_as_rg.name
	location		= var.resource_group_location
	allocation_method	= "Static"
}

resource "azurerm_lb" "linux_as_lb" {
	name			= "${var.availability_set_name_prefix}-fe-lb"
	resource_group_name	= azurerm_resource_group.linux_as_rg.name
	location		= var.resource_group_location

	frontend_ip_configuration {
		name			= "PublicIPAddress"
		public_ip_address_id	= azurerm_public_ip.linux_as_fe_pip.id
	}
}

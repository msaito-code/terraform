terraform {
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~> 3.0.2"
		}
	}
}

provider "azurerm" {
	features {}
}

resource "random_integer" "rg_suffix" {
	min = 1000
	max = 9999
}

resource "azurerm_resource_group" "vm_rg" {
	name		= "${var.vm_resource_group}-${var.vm_location}-${random_integer.rg_suffix.result}"
	location	= var.vm_location
}

resource "azurerm_virtual_network" "vnet" {
	name			= "vnet-${var.vm_location}"
	location		= var.vm_location
	resource_group_name	= azurerm_resource_group.vm_rg.name
	address_space		= [var.vnet_address_spaces[0]]
}

resource "azurerm_subnet" "subnet" {
	name			= "vm-${var.vm_location}.sn"
	resource_group_name	= azurerm_resource_group.vm_rg.name
	virtual_network_name	= azurerm_virtual_network.vnet.name
	address_prefixes		= ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "vm_nic" {
	name			= "vm-${var.vm_location}-nic"
	location		= var.vm_location
	resource_group_name	= azurerm_resource_group.vm_rg.name
	
	ip_configuration {
		name				= "Internal"
		subnet_id			= azurerm_subnet.subnet.id
		private_ip_address_allocation	= "Dynamic"
	}
}

resource "azurerm_linux_virtual_machine" "vm" {
	name			= "vm-${var.vm_location}"
	location		= var.vm_location
	resource_group_name	= azurerm_resource_group.vm_rg.name
	size			= "Standard_D2als_v7"
	disable_password_authentication = false
	admin_username		= "adminuser"
	admin_password		= "123@Trocar"
	network_interface_ids	= [
		azurerm_network_interface.vm_nic.id
	]

	os_disk {
		caching			= "ReadWrite"
		storage_account_type	= "Standard_LRS"
	}

	source_image_reference {
		publisher	= "Canonical"
		offer		= "ubuntu-24_04-lts"
		sku		= "server"
		version		= "latest"
	}
}

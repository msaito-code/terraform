resource "azurerm_resource_group" "linux_lb_rg" {
	name		= "${var.resource_group_name_prefix}-${var.vms_be_name_prefix}-${var.resource_group_location}"
	location	= var.resource_group_location
}

resource "azurerm_virtual_network" "linux_lb_vnet" {
	name			= "${var.vms_be_name_prefix}-vnet-${var.resource_group_location}"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	location		= var.resource_group_location
	address_space		= [var.vnet_available_address_spaces[0]]
}

resource "azurerm_subnet" "linux_vm_subnet" {
	name			= "${var.vms_be_name_prefix}-sb"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	virtual_network_name	= azurerm_virtual_network.linux_lb_vnet.name
	address_prefixes	= [var.first_cidr_block_mapping.first_subnet_block]
}

resource "azurerm_public_ip" "linux_lb_fe_pip" {
	name			= "${var.vms_be_name_prefix}-fe-pip"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	location		= var.resource_group_location
	sku			= "Standard"
	allocation_method	= "Static"
}

resource "azurerm_lb" "linux_fe_lb" {
	name			= "${var.vms_be_name_prefix}-fe-lb"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	location		= var.resource_group_location
	sku			= "Standard"

	frontend_ip_configuration {
		name			= "PublicIPAddress"
		public_ip_address_id	= azurerm_public_ip.linux_lb_fe_pip.id
	}
}

resource "azurerm_lb_backend_address_pool" "linux_be_pool" {
	loadbalancer_id	= azurerm_lb.linux_fe_lb.id
	name			= "BackEndAddressPool"
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_ss" {
	name			= "${var.vms_be_name_prefix}-ss-${var.resource_group_location}"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	location		= var.resource_group_location
	sku			= "Standard_D2als_v7"
	instances		= 2
	admin_username		= var.username
	admin_password		= "123@Trocar"

	disable_password_authentication = false

	user_data = base64encode(
			<<-EOF
			#!/bin/bash
			mkdir -p /var/www/html
			echo "Hello from $(hostname)!" > /var/www/html/index.html
			nohup busybox httpd -f -p 80 -h /var/www/html &
			EOF
		    )

	source_image_reference {
		publisher	= "Canonical"
		offer		= "ubuntu-24_04-lts"
		sku		= "server"
		version		= "latest"
	}

	os_disk {
		storage_account_type	= "Standard_LRS"
		caching			= "ReadWrite"
	}

	network_interface {
		name	= "${var.vms_be_name_prefix}-be-nic"
		primary	= true

		ip_configuration {
			name	  = "internal"
			primary	  = true
			subnet_id = azurerm_subnet.linux_vm_subnet.id

			load_balancer_backend_address_pool_ids = [
				azurerm_lb_backend_address_pool.linux_be_pool.id
			]
		}
	}
}

resource "azurerm_network_security_group" "linux_ss_nsg" {
	name			= "${var.vms_be_name_prefix}-be-nsg"
	resource_group_name	= azurerm_resource_group.linux_lb_rg.name
	location		= var.resource_group_location
	
	security_rule {
		name			= "Allow-HTTP"
		priority		= 100
		direction		= "Inbound"
		access			= "Allow"
		protocol		= "Tcp"
		source_port_range	= "*"
		destination_port_range	= "80"
		source_address_prefix	= "Internet"
		destination_address_prefix = "*"
	}

	security_rule {
		name		= "Allow-LB-Probe"
		priority	= 110
		direction	= "Inbound"
		access		= "Allow"
		protocol	= "*"
		source_port_range = "*"
		destination_port_range = "80"
		source_address_prefix = "AzureLoadBalancer"
		destination_address_prefix = "*"
	}
}

resource "azurerm_subnet_network_security_group_association" "sb_nsg" {
	subnet_id	= azurerm_subnet.linux_vm_subnet.id
	network_security_group_id	= azurerm_network_security_group.linux_ss_nsg.id
}

resource "azurerm_lb_probe" "http_probe" {
	name			= "http-probe"
	loadbalancer_id		= azurerm_lb.linux_fe_lb.id
	protocol		= "Http"
	port			= 80
	request_path		= "/index.html"
}

resource "azurerm_lb_rule" "http_rule" {
	name			= "http-rule"
	loadbalancer_id		= azurerm_lb.linux_fe_lb.id
	protocol		= "Tcp"
	frontend_port		= 80
	backend_port		= 80

	frontend_ip_configuration_name	= "PublicIPAddress"

	backend_address_pool_ids = [
		azurerm_lb_backend_address_pool.linux_be_pool.id
	]

	probe_id	= azurerm_lb_probe.http_probe.id
}

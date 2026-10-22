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

resource "azurerm_lb" "cluster_fe_lb" {
	name			= "${var.resource_prefix}-fe-lb"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	location		= var.resource_region
	sku			= "Standard"

	frontend_ip_configuration {
		name			= "PublicIPAddress"
		public_ip_address_id	= azurerm_public_ip.cluster_lb_pip.id
	}
}

resource "azurerm_lb_backend_address_pool" "cluster_be_pool" {
	loadbalancer_id	= azurerm_lb.cluster_fe_lb.id
	name		="BackendAddressPool"
}

resource "azurerm_lb_probe" "fe_lb_probe" {
	name		= "${var.resource_prefix}-http-probe"
	loadbalancer_id	= azurerm_lb.cluster_fe_lb.id
	protocol	= "Http"
	port		= 80
	request_path	= "/index.html"
}

resource "azurerm_lb_rule" "fe_lb_rule" {
	name		= "${var.resource_prefix}-http-rule"
	loadbalancer_id	= azurerm_lb.cluster_fe_lb.id
	protocol	= "Tcp"
	frontend_port	= 80
	backend_port	= 80

	frontend_ip_configuration_name	= "PublicIPAddress"

	backend_address_pool_ids = [
		azurerm_lb_backend_address_pool.cluster_be_pool.id
	]

	probe_id	= azurerm_lb_probe.fe_lb_probe.id
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_cluster" {
	name			= "${var.resource_prefix}-vmss"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	location		= var.resource_region
	sku			= "Standard_D2als_v7"
	instances		= 2
	admin_username		= var.admin_username
	admin_password		= var.admin_password

	disable_password_authentication = false

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
		name	= "${var.resource_prefix}-vmss-nic"
		primary = true

		ip_configuration {
			name	= "internal"
			primary = true

			subnet_id = azurerm_subnet.cluster_private_subnet.id

			load_balancer_backend_address_pool_ids = [
				azurerm_lb_backend_address_pool.cluster_be_pool.id
			]
		}
	}
}

resource "azurerm_network_security_group" "cluster_nsg" {
	name			= "${var.resource_prefix}-vmss-nsg"
	resource_group_name	= azurerm_resource_group.cluster_rg.name
	location		= var.resource_region

	security_rule {
		name		= "Allow-Inbound-Http"
		priority	= 100
		direction	= "Inbound"
		access		= "Allow"
		protocol	= "Tcp"

		source_port_range	= "*"
		destination_port_range	= "80"
		source_address_prefix	= "Internet"

		destination_address_prefix	= "*"
	}

	security_rule {
		name		= "Allow-LB-Probe"
		priority	= 110
		direction	= "Inbound"
		access		= "Allow"
		protocol	= "*"

		source_port_range	= "*"
		destination_port_range	= "80"
		source_address_prefix	= "AzureLoadBalancer"

		destination_address_prefix = "*"
		
	}
}

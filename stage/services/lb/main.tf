data "terraform_remote_state" "vnet_state" {
	backend = "azurerm"

	config = {
		storage_account_name 	= "tfstateclustersteastus"
		container_name		= "tfstate-cluster-container"
		key			= "cluster_vnet.terraform.tfstate"

		use_azuread_auth	= true
	}
}

resource "azurerm_lb" "cluster_fe_lb" {
	name			= "${var.resource_prefix}-fe-lb"
	resource_group_name	= data.terraform_remote_state.vnet_state.outputs.cluster_rg_name
	location		= var.resource_region
	sku			= "Standard"

	frontend_ip_configuration {
		name			= "PublicIPAddress"
		public_ip_address_id	= data.terraform_remote_state.vnet_state.outputs.cluster_fe_lb_pip_id
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

resource "azurerm_lb" "cluster_fe_lb" {
	name			= "${var.resource_prefix}-fe-lb"
	resource_group_name	= var.cluster_rg_name
	location		= var.resource_region
	sku			= "Standard"

	frontend_ip_configuration {
		name			= "PublicIPAddress"
		public_ip_address_id	= var.cluster_fe_lb_pip_id
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

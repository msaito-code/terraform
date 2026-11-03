resource "azurerm_linux_virtual_machine_scale_set" "linux_cluster" {
	name			= "${var.resource_prefix}-vmss"
	resource_group_name	= var.cluster_rg_name
	location		= var.resource_region
	sku			= "Standard_D2als_v7"
	instances		= 2
	admin_username		= var.admin_username
	admin_password		= var.admin_password
	custom_data = base64encode(templatefile("${path.module}/user-data.sh", {server_port = 80}))

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

			subnet_id = var.cluster_private_subnet_id

			load_balancer_backend_address_pool_ids = [
				var.cluster_be_pool_id
			]
		}
	}
}

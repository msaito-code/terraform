data "terraform_remote_state" "vnet_state" {
        backend = "azurerm"

        config = {
                storage_account_name    = "tfstateclustersteastus"
                container_name          = "tfstate-cluster-container"
                key                     = "cluster_vnet.terraform.tfstate"
                use_azuread_auth        = true
        }
}

data "terraform_remote_state" "lb_state" {
        backend = "azurerm"

        config = {
                storage_account_name    = "tfstateclustersteastus"
                container_name          = "tfstate-cluster-container"
                key                     = "cluster_lb.terraform.tfstate"
                use_azuread_auth        = true
        }
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_cluster" {
	name			= "${var.resource_prefix}-vmss"
	resource_group_name	= data.terraform_remote_state.vnet_state.outputs.cluster_rg_name
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

			subnet_id = data.terraform_remote_state.vnet_state.outputs.cluster_private_subnet_id

			load_balancer_backend_address_pool_ids = [
				data.terraform_remote_state.lb_state.outputs.cluster_be_pool_id
			]
		}
	}
}

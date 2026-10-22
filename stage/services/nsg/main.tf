data "terraform_remote_state" "vnet_state" {
        backend = "azurerm"

        config = {
                storage_account_name    = "tfstateclustersteastus"
                container_name          = "tfstate-cluster-container"
                key                     = "cluster_vnet.terraform.tfstate"
		use_azuread_auth	= true
        }
}

resource "azurerm_network_security_group" "cluster_nsg" {
	name			= "${var.resource_prefix}-vmss-nsg"
	resource_group_name	= data.terraform_remote_state.vnet_state.outputs.cluster_rg_name
	location		= var.resource_region


	security_rule {
		name		= "Allow-HTTP"
		priority	= 100
		direction	= "Inbound"
		access		= "Allow"
		protocol	= "Tcp"

		source_port_range	= "*"
		destination_port_range	= 80
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

resource "azurerm_subnet_network_security_group_association" "cluster_nsg_assoc" {
	subnet_id			= data.terraform_remote_state.vnet_state.outputs.cluster_private_subnet_id
	network_security_group_id 	= azurerm_network_security_group.cluster_nsg.id
}

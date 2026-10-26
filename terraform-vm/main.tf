data "azurerm_user_assigned_identity" "terraform_vm" {
    name                = "id-terraform-workstation"
    resource_group_name = "ssh-vault-rg"
}

data "azurerm_ssh_public_key" "default_ssh" {
	name			= "default-ssh-key"
	resource_group_name	= "ssh-vault-rg"
}

resource "azurerm_resource_group" "tf_vm_rg" {
	name	 = "rg-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
	location = var.tf_vm_rg_location
}

resource "azurerm_virtual_network" "tf_vm_vnet" {
	name	 		= "vnet-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
	location 		= var.tf_vm_rg_location
	resource_group_name	= azurerm_resource_group.tf_vm_rg.name
	address_space 		= [var.tf_vm_vnet]
}

resource "azurerm_subnet" "tf_vm_subnet" {
	name			= "snet-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
	resource_group_name	= azurerm_resource_group.tf_vm_rg.name
	virtual_network_name	= azurerm_virtual_network.tf_vm_vnet.name
	address_prefixes	= [var.tf_vm_vnet]
}

resource "azurerm_public_ip" "tf_vm_pip" {
	name			= "pip-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
	resource_group_name	= azurerm_resource_group.tf_vm_rg.name
	location		= var.tf_vm_rg_location
	allocation_method	= "Static"
	sku			= "Basic"
}

resource "azurerm_network_interface" "tf_vm_nic" {
	name			= "nic-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
	resource_group_name	= azurerm_resource_group.tf_vm_rg.name
	location		= var.tf_vm_rg_location

	ip_configuration {
		name				= "TerraformPrivateIP"
		subnet_id			= azurerm_subnet.tf_vm_subnet.id
		private_ip_address_location	= "Dynamic"
	}
}

resource "azurerm_linux_virtual_machine" "tf_vm" {
	name			= "vm-${var.tf_vm_rg_prefix}-${var.tf_vm_rg_location}"
	resource_group_name	= azurerm_resource_group.tf_vm_rg.name
	location		= var.tf_vm_rg_location
	size			= "Standard_B2ats_v2"
	admin_username		= "azureuser"
	network_interface_ids	= [
		azurerm_network_interface.tf_vm_nic.id
	]

	admin_ssh_key {
		username	= "azureuser"
		public_key	= data.azurerm_ssh_public_key.default_ssh.public_key		
	}

	identity {
		type = "UserAssigned"

		identity_ids = [
			data.azurerm_user_assigned_identity.terraform_vm.id
		]
	}

	data "azurerm_client_config" "current" {}
	data "azurerm_subscription" "current" {}

	custom_data = base64encode(file("${path.module}/cloud-init.yaml", {
		managed_identity_client_id 	= data.azurerm_user_ssigned_identity.terraform_vm.client_id,
		subscription_id			= data.azurerm_subscription.current.subscription_id,
		tenant_id			= data.azurerm_client_config.current.tenant_id,

		key_vault_name	= "github-kv-default",
		git_name	= "msaito777",
		git_email	= "matheus.saito0201@gmail.com",
		github_repo	= "git@github.com:msaito-code/terraform.git"
	}))

	os_disk {
		name			="osdisk-${var.tf_vm_prefix}-${var.tf_vm_rg_location}"
		storage_account_type	= "Standard_LRS"
		caching			= "ReadWrite"
	}

	source_image_reference {
		publisher = "Canonical"
		offer	  = "ubuntu-24_04-lts"
		sku	  = "server"
		version	  = "latest"
	}
}

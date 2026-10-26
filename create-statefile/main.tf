provider "azurerm" {
	features {}
}

data "azurerm_resource_group" "tfstate_blob_rg" {
	name = "rg-terraform-state-sec-portfolio"
}

data "azurerm_storage_account" "tfstate_storage" {
	name 			= "tfstatesec61bb283b"
	resource_group_name	= data.azurerm_resource_group.tfstate_blob_rg.name
}

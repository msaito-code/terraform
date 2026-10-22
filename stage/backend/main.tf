resource "azurerm_resource_group" "st_rg" {
	name		= "rg-${var.resource_prefix}-cluster-st"
	location	= var.resource_region
}

resource "azurerm_storage_account" "tfstate_st" {
	name			= "${var.resource_prefix}clusterst${var.resource_region}"
	resource_group_name	= azurerm_resource_group.st_rg.name
	location		= var.resource_region
	account_tier		= "Standard"
	account_replication_type= "LRS"
	access_tier		= "Hot"
}

resource "azurerm_storage_container" "tfstate_container" {
	name			= "${var.resource_prefix}-cluster-container"
	storage_account_name	= azurerm_storage_account.tfstate_st.name
	container_access_type	= "private"
}

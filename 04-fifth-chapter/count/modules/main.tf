

resource "azurerm_resource_group" "rg" {
    name = "test-rg"
    location = "eastus" 
}

resource "azurerm_user_assigned_identity" "ids" {
    location = azurerm_resource_group.rg.location
    name = var.users
    resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network" "vnet" {
    name = var.vnet_name
    resource_group_name = var.rg_name
    location = var.rg_location
    address_space = [var.address_space]
}

resource "azurerm_subnet" "private_snet" {
    name = var.priv_snet_name
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.address_prefix]
}
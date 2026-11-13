output "vnet" {
    value = azurerm_virtual_network.vnet
}

output "snet" {
    value = azurerm_subnet.private_snet
}
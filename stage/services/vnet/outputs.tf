output "rg_id" {
	value = azurerm_resource_group.cluster_rg.id
}

output "vnet_id" {
	value = azurerm_virtual_network.cluster_vnet.id
}

output "cluster_subnet_id" {
	value = azurerm_subnet.cluster_private_subnet.id
}

output "cluster_fe_lb_pip" {
	value = azurerm_public_ip.cluster_lb_pip.ip_address
}

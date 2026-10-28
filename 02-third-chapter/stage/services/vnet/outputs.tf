output "cluster_rg_name" {
	value = azurerm_resource_group.cluster_rg.name
}

output "cluster_fe_lb_pip_id" {
	value = azurerm_public_ip.cluster_lb_pip.id
}

output "cluster_private_subnet_id" {
	value = azurerm_subnet.cluster_private_subnet.id
}

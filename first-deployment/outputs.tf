output "vm_rg_id" {
	value	= azurerm_resource_group.vm_rg.id
}

output "vnet_id" {
	value	= azurerm_virtual_network.vnet.id
}

output "vm_private_ip" {
	value	= azurerm_linux_virtual_machine.vm.private_ip_addresses[0]
}

output "vm_public_ip" {
	value	= azurerm_public_ip.vm_pip.ip_address
}

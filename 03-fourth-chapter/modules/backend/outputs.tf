output "tfstate_st_name" {
	value = azurerm_storage_account.tfstate_st.name
}

output "tfstate_container_name" {
	value = azurerm_storage_container.tfstate_container.name
}

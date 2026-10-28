output "blob_tfstate_rg_id" {
	value = data.azurerm_resource_group.tfstate_blob_rg.id
}

output "blob_tfstate_id" {
	value = data.azurerm_storage_account.tfstate_storage.id
}

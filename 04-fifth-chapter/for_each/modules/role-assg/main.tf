resource "azurerm_role_assignment" "reader_role" {
    scope = var.vnet_id
    role_definition_name = var.role_name
    principal_id = var.user_id
}
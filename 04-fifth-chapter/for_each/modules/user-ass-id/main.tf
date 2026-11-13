resource "azurerm_user_assigned_identity" "ids" {
    location = var.rg_location
    name = var.user
    resource_group_name = var.rg_name

    count = var.create_user ? 1 : 0
    tags = var.id_tag
}
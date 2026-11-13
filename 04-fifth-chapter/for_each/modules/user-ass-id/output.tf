output "user_info" {
    value = try(azurerm_user_assigned_identity.ids[0], null)
}
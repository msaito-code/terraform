output "user_ids" {
    value = values(module.user_ids)[*]
}
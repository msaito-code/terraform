output "user_ids" {
    value = values(module.user_ids)[*]
}

output "upper_names" {
    value = [for name in var.usernames : upper(name)]
}

output "permissions" {
    value = [for name, role in var.permissions : "${name} can do ${role}"]
}
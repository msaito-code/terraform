output "user_ids" {
    value = values(module.users)[*].user_info
}

output "upper_names" {
    value = [for name in var.usernames : upper(name)]
}

output "permissions_for_expressions" {
    value = [for name, role in var.permissions : "${name}s ${role}"]
}

output "permissions_for_string_directive" {
    value = "%{for name, role in var.permissions}${name} => ${role}, %{ endfor }"
}

output "vnet_snet_info" {
    value = module.vnet
}
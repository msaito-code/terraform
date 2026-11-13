terraform {
    required_version = ">= 1.0"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0.0"
        }
    }
}

provider "azurerm" {
    features {}
}

module "rg" {
    source = "../modules/rg"

    rg_location = var.rg_info["location"]
    rg_name = var.rg_info["name"]
}

module "users" {
    source = "../modules/user-ass-id"

    rg_location = var.rg_info["location"]
    rg_name = var.rg_info["name"]

    for_each = toset(var.usernames)
    user = each.value
    create_user = var.create_users[each.value]
    id_tag = {
        key = "Role",
        value = each.value
    }

    depends_on = [ module.rg ]
}

module "vnet" {
    source = "../modules/vnet"

    rg_location = var.rg_info["location"]
    rg_name = var.rg_info["name"]

    vnet_name = var.vnet_info["vnet_name"]
    address_space = var.vnet_info["address_space"]
    priv_snet_name = var.vnet_info["snet_name"]
    address_prefix = var.vnet_info["address_prefix"]

    depends_on = [ module.rg ]
}

module "user_assignment" {
    source = "../modules/role-assg"

    for_each = toset([
        for username in var.usernames : username
        if var.create_users[username]
    ])

    user_id = module.users[each.key].user_info.principal_id
    vnet_id = module.vnet.vnet.id
    role_name = module.users[each.key].user_info.name

    depends_on = [ module.rg, module.users, module.vnet ]
}
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

module "user_ids" {
    source = "../modules"

    for_each = toset(var.usernames)
    users = each.value
}
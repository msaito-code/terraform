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

    count = length(var.usernames)
    users = var.usernames[count.index]
}
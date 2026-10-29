terraform {
    backend "azurerm" {
        resource_group_name     = "rg-tfstate-cluster-st"
        storage_account_name    = "tfstateclustersteastus"
        container_name          = "tfstate-cluster-container"
        key                     = "prod_cluster_vnet.terraform.tfstate"
    }
}

provider "azurerm" {
    features {}
}

module "vnet_settings" {
    source = "../../03-fourth-chapter/modules/services/vnet"

    resource_region = "eastus"
    resource_prefix = "ubu-cluster-prod"
    vnet_address_space = "10.1.0.0/16"
    snet_address_prefix = "10.1.0.0/24"
}
terraform {
    backend "azurerm" {
        resource_group_name     = "rg-tfstate-cluster-st"
        storage_account_name    = "tfstateclustersteastus"
        container_name          = "tfstate-cluster-container"
        key                     = "stage_cluster.terraform.tfstate"
    }
}

provider "azurerm" {
    features {}
}

module "vnet_settings" {
    source = "../../03-fourth-chapter/modules/services/vnet"

    resource_region = "eastus"
    resource_prefix = "ubu-cluster-stg"
    vnet_address_space = "10.0.0.0/16"
    snet_address_prefix = "10.0.0.0/24"
}

module "lb_settings" {
    source = "../../03-fourth-chapter/modules/services/lb"

    resource_region = "eastus"
    resource_prefix = "ubu-cluster-stg"
    
    cluster_rg_name = module.vnet_settings.cluster_rg_name
    cluster_fe_lb_pip_id = module.vnet_settings.cluster_fe_lb_pip_id
}
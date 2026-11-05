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
    source = "github.com/msaito-code/terraform/03-fourth-chapter/modules/services/vnet?ref=v0.0.3"

    resource_region = local.resource_region
    resource_prefix = local.resource_prefix
    vnet_address_space = local.vnet_address_space
    snet_address_prefix = local.snet_address_prefix
}

module "lb_settings" {
    source = "github.com/msaito-code/terraform/03-fourth-chapter/modules/services/lb?ref=v0.0.3"

    resource_region = local.resource_region
    resource_prefix = local.resource_prefix
    
    cluster_rg_name = local.cluster_rg_name
    cluster_fe_lb_pip_id = local.cluster_fe_lb_pip_id
}

module "nsg_settings" {
    source = "github.com/msaito-code/terraform/03-fourth-chapter/modules/services/nsg?ref=v0.0.3"

    resource_region = local.resource_region
    resource_prefix = local.resource_prefix
    cluster_rg_name = local.cluster_rg_name
    cluster_private_subnet_id = local.cluster_private_subnet_id
}

module "webcluster_settings" {
    source = "github.com/msaito-code/terraform/03-fourth-chapter/modules/services/webserver-cluster?ref=v0.0.3"

    resource_region = local.resource_region
    resource_prefix = local.resource_prefix
    cluster_rg_name = local.cluster_rg_name
    cluster_private_subnet_id = local.cluster_private_subnet_id
    admin_username = local.admin_username
    admin_password = local.admin_password
    cluster_be_pool_id = local.cluster_be_pool_id
}
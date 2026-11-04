locals {
    resource_region = "eastus"
    resource_prefix = "ubu-cluster-stg"
    vnet_address_space = "10.0.0.0/16"
    snet_address_prefix = "10.0.0.0/24"    
    cluster_rg_name = module.vnet_settings.cluster_rg_name
    cluster_fe_lb_pip_id = module.vnet_settings.cluster_fe_lb_pip_id
    admin_username = "azureuser"
    admin_password = "QualquerCoisa@123"
    cluster_private_subnet_id = module.vnet_settings.cluster_private_subnet_id
    cluster_be_pool_id = module.lb_settings.cluster_be_pool_id
}
terraform {
	required_version = ">= 1.0"
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~> 3.0.0"
		}
	}
	backend "azurerm" {
                resource_group_name     = "rg-tfstate-cluster-st"
                storage_account_name    = "tfstateclustersteastus"
                container_name          = "tfstate-cluster-container"
                key                     = "cluster_nsg.terraform.tfstate"
        }
}

provider "azurerm" {
	features {}
}

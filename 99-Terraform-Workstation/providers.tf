terraform {
	required_version = ">=1.0"
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "~> 3.0"
		}
	}
	backend "azurerm" {
		resource_group_name	= "rg-terraform-state-sec-portfolio"
		storage_account_name	= "tfstatesec61bb283b"
		container_name		= "tfstate"
		key			= "terraform-vm.terraform.tfstate"
	}
}

provider "azurerm" {
	features {}
}

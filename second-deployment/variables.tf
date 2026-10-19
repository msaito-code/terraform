variable "resource_group_location" {
	description 	= "Location of the resources"
	type		= string
	default		= "eastus2"
}

variable "resource_group_name_prefix" {
	description	= "Prefix of the resource group name"
	type		= string
	default		= "rg"
}

variable "vms_be_name_prefix" {
	description	= "Prefix for the Linux Ubuntu VMs in the backend pool of the Load Balancer"
	type		= string
	default		= "ubu-be"
}

variable "vnet_available_address_spaces" {
	description	= "Available address spaces for VNets"
	type		= list(string)
	default		= [
		"10.0.0.0/16",
		"10.16.0.0/16",
		"172.16.0.0/16"
	]
}

variable "first_cidr_block_mapping" {
	description	= "Mapping of the available subnets"
	type		= map(string)
	default		= {
		first_subnet_block 	= "10.0.1.0/24",
		second_subnet_block 	= "10.0.2.0/24"
	}
}

variable "username" {
	description	= "The username for the local account that will be created on the new VM"
	type		= string
	default		= "azureuser"
}

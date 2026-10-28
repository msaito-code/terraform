variable "resource_region" {
	description	= "Region in which the resources are deployed"
	type		= string
	default		= "eastus"
}

variable "resource_prefix" {
	description	= "Prefix of the resources"
	type		= string
	default		= "ubu-cluster"
}

variable "vnet_address_space" {
	description	= "Available Vnet address spaces"
	type		= list(string)
	default		= [
		"10.0.0.0/16",
		"10.1.0.0/16"
	]
}

variable "admin_username" {
	description	= "Admin username for the VMSS using environment keys"
	type		= string
	sensitive	= true
}

variable "admin_password" {
	description	= "Admin password for the VMSS using environment keys"
	type		= string
	sensitive	= true
}

variable "resource_region" {
	description	= "Region in which the resources are deployed"
	type		= string
}

variable "resource_prefix" {
	description	= "Prefix of the resources"
	type		= string
}

variable "vnet_address_space" {
	description	= "Available Vnet address spaces"
	type		= string
}

variable "snet_address_prefix" {
	description = "Address Prefix for the Cluster Subnet"
	type		= string
}
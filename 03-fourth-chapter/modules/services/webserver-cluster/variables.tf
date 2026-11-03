variable "resource_region" {
	description	= "Region in which the resources are deployed"
	type		= string
}

variable "resource_prefix" {
	description	= "Prefix of the resources"
	type		= string
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

variable "cluster_be_pool_id" {
	type = string
}

variable "cluster_private_subnet_id" {
	type = string
}

variable "cluster_rg_name" {
	type = string
}
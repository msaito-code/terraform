variable "resource_region" {
	description	= "Region in which the resources are deployed"
	type		= string
}

variable "resource_prefix" {
	description	= "Prefix of the resources"
	type		= string
}

variable "cluster_rg_name" {
	type = string
}

variable "cluster_fe_lb_pip_id" {
	type = string
}
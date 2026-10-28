variable "resource_region" {
	description 	= "Region of the resources"
	type		=  string
	default		= "eastus"
}

variable "resource_prefix" {
	description	= "Prefix of the resources"
	type		= string
	default		= "tfstate"
}

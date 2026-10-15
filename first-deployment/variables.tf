variable "vm_resource_group" {
	description	= "Resource Group for VMs"
	type		= string
	default		= "vm-rg"
}

variable "vm_location" {
	description	= "Location of the VMs"
	type		= string
	default		= "eastus"
}

variable "vnet_address_spaces" {
	description	= "Available VNet Address spaces"
	type		= list(string)
	default		= [
		"10.0.0.0/16",
		"10.1.0.0/16"
	]
}

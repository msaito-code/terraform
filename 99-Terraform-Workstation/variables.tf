variable "tf_vm_rg_location" {
	description = "Location of the Resource Group for the VM used in Terraform"
	type	= string
	default	= "westus3"
}

variable "tf_vm_prefix" {
	description = "Prefix for the Terraform VM and associated resources"
	type	= string
	default = "dev-tf"
}

variable "tf_vm_vnet" {
	description = "Address space for the Terraform VM VNet"
	type	= string
	default	= "10.0.0.0/16"
}

variable "tf_vm_subnet" {
	description = "Private subnet for the Terraform VM"
	type	= string
	default	= "10.0.1.0/24"
}

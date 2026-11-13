variable "rg_info" {
    type = map(string)
    default = {
      "location" = "eastus"
      "name" = "test-rg"
    }
}

variable "usernames" {
    type = list(string)
    default = ["Reader", "Contributor", "Owner"]
}

variable "permissions" {
    type = map(string)
    default = {
        Owner = "can do anything"
        Contributor = "can't alter permissions"
        Reader = "can read resource metadata"
    }
}

variable "create_users" {
    type = map(bool)
    default = {
        Owner = true
        Contributor = true
        Reader = false
    }
}

variable "vnet_info" {
    type = map(string)
    default = {
        "vnet_name" = "vnet"
        "address_space" = "10.0.0.0/16"
        "snet_name" = "private_snet"
        "address_prefix" = "10.0.1.0/24"
    }
}
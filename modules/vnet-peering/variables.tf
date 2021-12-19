variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the VM to create. Defaults to the location of the resource group."
  type        = string
  default     = null
}

variable "peering" {
  description = "Peered vnets properties"
  type        = list(object({
                  vnet_id = string
                  vnet_name = string
                  allow_virtual_network_access = bool
                  allow_forwarded_traffic      = bool
                  allow_gateway_transit        = bool
                  use_remote_gateways          = bool
  }))
}



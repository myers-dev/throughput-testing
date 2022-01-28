variable "location" {
  description = "The Azure Region where the Resources should exist."
  type        = string
}

variable "resource_group_name" {
  description = "The Name which should be used for this Resource Group."
  type        = string

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90 && can(regex("^[a-zA-Z0-9-._\\(\\)]+[a-zA-Z0-9-_\\(\\)]$", var.resource_group_name))
    error_message = "Invalid name (check Azure Resource naming restrictions for more info)."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the resources"
  type        = map(string)
  default     = {}
}

variable "lock_level" {
  description = "Specifies the Level to be used for this RG Lock. Possible values are Empty (no lock), CanNotDelete and ReadOnly."
  type        = string
  default     = ""
}

variable "security_group_name" {
  description = "NSG Name"
  type        = string
  default     = "nsg"
}

variable "vnets" {
  description = "List of Vnets names"
  type = map(object(
    {
      address_space                                  = list(string)
      subnet_names                                   = list(string)
      subnet_prefixes                                = list(string)
      enforce_private_link_endpoint_network_policies = map(any)
      enforce_private_link_service_network_policies  = map(any)
    }
  ))
  default = {}
}

variable "vmssscale" {
  description = "Number of instances in VMSS"
}

variable "idps" {
  description = "idps mode of the firewall. Allowed values are Alert,Deny,Off"
}

variable "testtype" {
  description = "Test type. Allowed Values are : vegeta, iperf3"
}

variable "testduration" {
  description = "Test duration in minutes"
}

variable "testprotocol" {
  description = "Test protocol. Allowed values are http, https. Ignored if testtype is iperf3"
  default     = "http"
}

variable "testiperf3flows" {
  description = "iperf3 specific. Number of flows"
  default     = "64"
}

variable "vmss_size" {
  description = "VMSS VM Size"
  default     = "Standard_D4_v4"
}
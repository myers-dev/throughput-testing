variable "subnet_ids" {
  description = "Subnet IDs where VM will be placed"
  type        = list(string)
}

variable "name" {
    description = "Name of VM"
    type        = string
    default     = "LinuxVM"
}

variable "resource_group_name" {
    description = "Resource Group Name"
    type        = string
}

variable "location" {
  description = "The location of the vnet to create. Defaults to the location of the resource group."
  type        = string
  default     = null
}

variable "enable_ip_forwarding" {
  type = bool
  default = false
}

variable "vm_size" {
  description = "Size of the VM , exampel Standard_DS4_v2"
  default = "Standard_DS4_v2"
  type = string
}

variable storage_image_reference {
  type = object({
    publisher = string
    offer = string
    sku = string
    version = string
    })
}

variable plan {
  type = object({
    name = string
    publisher = string
    product = string
  })
}

variable zone {
  type = string
}

variable public_ip_address_id {
  type = string
}

variable "admin_username" {
  description = "Admin username"
  type = string
}

variable "admin_password" {
  description = "Admin password"
  sensitive = true
}

variable "disable_password_authentication" {
  description = "disable_password_authentication"
  type = bool
}

variable "ssh_key_data" {
  description = "ssh_key_data"
  type = string
}


